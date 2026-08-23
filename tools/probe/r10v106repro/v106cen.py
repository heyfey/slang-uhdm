#!/usr/bin/env python3
"""v106cen.py <golden> <pris> <ship> [label]
Independent, view-general, SPAN-FREE and PATH-FREE census of every
param_assign cell AND every parameter object in a UHDM database.

key     = (top-level listing edge, FULL scope-name chain, parameter name)
payload = Rhs kind + vpiSize + vpiConstType + value tag + vpiDecompile
          + Rhs typespec shape (none / DANGLING / <kind>) + the same for the
          param_assign Lhs and the owning parameter object.
Multiset (Counter) join -- collisions merge, no last-writer loss.
Classification per KEY: TO_GOLDEN / AWAY_LOST_GOOD / AWAY_NEW_WRONG /
LATERAL / STILL_WRONG.
"""
import re, sys, subprocess, collections, os
DUMP = os.environ.get('UHDM_DUMP', "/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump")
OBJ  = re.compile(r'^(\s*)\\_([A-Za-z_0-9]+): ?(.*)$')
ATTR = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')
VALTAGS = ('BIN','OCT','HEX','INT','UINT','DEC','REAL','STRING','SCAL','TIME')

def lines_of(p):
    if p.endswith('.dump') or p.endswith('.txt'):
        return open(p, errors='replace').read().split('\n')
    r = subprocess.run([DUMP, p], capture_output=True, text=True)
    return r.stdout.split('\n')

def parse(p):
    root = {'kind':'ROOT','hdr':'','attrs':[],'kids':[]}
    stack = [(-1, root)]; pend = None
    for ln in lines_of(p):
        m = OBJ.match(ln)
        if m:
            ind = len(m.group(1))
            node = {'kind':m.group(2),'hdr':m.group(3),'attrs':[],'kids':[]}
            while stack and stack[-1][0] >= ind: stack.pop()
            (stack[-1][1] if stack else root)['kids'].append((pend, node))
            pend = None; stack.append((ind, node)); continue
        m = ATTR.match(ln)
        if m:
            ind = len(m.group(1))
            while stack and stack[-1][0] >= ind: stack.pop()
            node = stack[-1][1] if stack else root
            v = m.group(3)
            if v == '': pend = m.group(2)
            else: node['attrs'].append((m.group(2), v)); pend = None
    return root

def attr(n,k,d=None):
    if n is None: return d
    for a,v in n['attrs']:
        if a==k: return v
    return d
def kid(n,e):
    if n is None: return None
    for a,c in n['kids']:
        if a==e: return c
    return None
def valtag(n):
    if n is None: return '-'
    for k,v in n['attrs']:
        if k in VALTAGS: return f'{k}:{v}'
    return '-'
def nameof(n):
    m = re.match(r'([A-Za-z_0-9:$@\.\[\]\\]*)\s*\(([^)]*)\)', n['hdr'])
    if m: return (m.group(2) or m.group(1))
    return n['hdr'].split(',')[0].strip()
def basename(s):
    s = s.split('@')[-1]
    return s.split('::')[-1].split('.')[-1]
def tsshape(n):
    """typespec shape of an object: none / DANGLING / <actual kind>[+size]"""
    if n is None: return '?'
    ts = kid(n,'vpiTypespec')
    if ts is None: return 'none'
    if ts['kind'] != 'ref_typespec': return 'direct:'+ts['kind']
    act = kid(ts,'vpiActual')
    if act is None: return 'DANGLING'
    extra = ''
    r = kid(act,'vpiRange')
    if r is not None:
        extra = '[%s:%s]' % (attr(kid(r,'vpiLeftRange'),'vpiDecompile','?'),
                             attr(kid(r,'vpiRightRange'),'vpiDecompile','?'))
    return act['kind'] + extra

SCOPEK = ('package','module_inst','class_defn','function','task','gen_scope',
          'gen_scope_array','interface_inst','program','design','begin',
          'named_begin','class_typespec','fork','named_fork','instance')

def exprpay(n, tag):
    if n is None: return f'{tag}=absent'
    if n['kind'] != 'constant':
        return f'{tag}={n["kind"]} ts={tsshape(n)}'
    return (f'{tag}=constant sz={attr(n,"vpiSize","-")} '
            f'ct={attr(n,"vpiConstType","-")} {valtag(n)} '
            f'dec={attr(n,"vpiDecompile","-")} ts={tsshape(n)}')

def cells(root):
    out = collections.Counter()
    def walk(n, chain, redge):
        for e,c in n['kids']:
            r2 = redge if redge else (e or '')
            ch = chain
            if c['kind'] in SCOPEK:
                ch = chain + [basename(nameof(c))]
            if c['kind'] == 'param_assign':
                lhs = kid(c,'vpiLhs'); rhs = kid(c,'vpiRhs')
                ln = basename(nameof(lhs)) if lhs is not None else '?'
                key = ('PA', r2, '/'.join(ch), ln)
                pay = exprpay(rhs,'R') + ' | Lts=' + tsshape(lhs)
                out[(key,pay)] += 1
            elif c['kind'] == 'parameter':
                key = ('PARAM', r2, '/'.join(ch), basename(nameof(c)))
                pay = (f'sz={attr(c,"vpiSize","-")} {valtag(c)} '
                       f'dec={attr(c,"vpiDecompile","-")} ts={tsshape(c)} '
                       f'loc={attr(c,"vpiLocalParam","-")}')
                out[(key,pay)] += 1
            walk(c, ch, r2)
    walk(root, [], '')
    return out

FIELD = os.environ.get('FIELD','')
def project(pay):
    """Project the payload onto ONE Compare-visible field so a per-field
    regression cannot hide inside a whole-payload LATERAL."""
    if not FIELD: return pay
    if FIELD == 'sz':
        m = re.search(r'sz=(\S+)', pay);  return 'sz=' + (m.group(1) if m else '-')
    if FIELD == 'ts':
        m = re.search(r'(?<!L)ts=(\S+)', pay); return 'ts=' + (m.group(1) if m else '-')
    if FIELD == 'lts':
        m = re.search(r'Lts=(\S+)', pay); return 'Lts=' + (m.group(1) if m else '-')
    if FIELD == 'dec':
        m = re.search(r'dec=(\S+)', pay); return 'dec=' + (m.group(1) if m else '-')
    if FIELD == 'ct':
        m = re.search(r'ct=(\S+)', pay);  return 'ct=' + (m.group(1) if m else '-')
    if FIELD == 'val':
        m = re.search(r'((?:BIN|OCT|HEX|INT|UINT|DEC|REAL|STRING|SCAL|TIME):\S*)', pay)
        return 'val=' + (m.group(1) if m else '-')
    if FIELD == 'kind':
        m = re.search(r'R=(\S+)', pay); return 'R=' + (m.group(1) if m else '-')
    raise SystemExit('bad FIELD')
def bag(p):
    b = collections.defaultdict(collections.Counter)
    for (k,pay),c in cells(parse(p)).items(): b[k][project(pay)] += c
    return b

def main():
    G,P,S = bag(sys.argv[1]), bag(sys.argv[2]), bag(sys.argv[3])
    lab = sys.argv[4] if len(sys.argv) > 4 else ''
    verbose = os.environ.get('V','1') != '0'
    keys = set(G)|set(P)|set(S)
    tg=alg=anw=lat=stw=0; det=[]
    for k in sorted(keys):
        g,p,s = G[k],P[k],S[k]
        pok, sok = (p==g), (s==g)
        if p == s:
            if not sok: stw += 1; det.append(('STILL_WRONG',k,g,p,s))
            continue
        if sok and not pok: tg += 1; det.append(('TO_GOLDEN',k,g,p,s))
        elif pok and not sok: alg += 1; det.append(('AWAY_LOST_GOOD',k,g,p,s))
        else: lat += 1; det.append(('LATERAL',k,g,p,s))
    print(f'V106CEN {lab}: TO_GOLDEN={tg} AWAY_LOST_GOOD={alg} LATERAL={lat} '
          f'STILL_WRONG={stw} keys={len(keys)}')
    if verbose:
        for t,k,g,p,s in det:
            if t == 'STILL_WRONG' and os.environ.get('SW','0') != '1': continue
            print(f'  {t} {k}\n     G {dict(g)}\n     P {dict(p)}\n     S {dict(s)}')
main()
