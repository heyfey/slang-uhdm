#!/usr/bin/env python3
"""r10uvm106 census: param_assign Rhs constants, keyed by owner chain + span +
Lhs name + declared-type shape.  Reads uhdm-dump TEXT (a .dump file or a .uhdm
which is dumped on the fly).  LHS is always golden.

Key   = (owner-chain kinds+names, param_assign span, Lhs param name)
Payload = Rhs constant: decompile | vpiSize | vpiConstType | valuetag |
          typespec presence/actual-kind   (+ Lhs parameter's own ts presence)
No vpiFullName in the payload (dump-only, never Compared) except where asked.
"""
import re, sys, subprocess, collections, os

DUMP = "/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump"
OBJ = re.compile(r'^(\s*)\\_([A-Za-z_0-9]+): ?(.*)$')
ATTR = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')
VALTAGS = ('BIN','OCT','HEX','INT','UINT','DEC','REAL','STRING','SCAL','TIME')

def lines_of(path):
    if path.endswith('.dump') or path.endswith('.txt'):
        return open(path, errors='replace').read().split('\n')
    return subprocess.run([DUMP, path], capture_output=True, text=True).stdout.split('\n')

def parse(path):
    root = {'kind':'ROOT','hdr':'','attrs':[],'kids':[]}
    stack=[(-1,root)]; pend=None
    for ln in lines_of(path):
        m = OBJ.match(ln)
        if m:
            ind=len(m.group(1))
            node={'kind':m.group(2),'hdr':m.group(3),'attrs':[],'kids':[]}
            while stack and stack[-1][0]>=ind: stack.pop()
            (stack[-1][1] if stack else root)['kids'].append((pend,node)); pend=None
            stack.append((ind,node)); continue
        m = ATTR.match(ln)
        if m:
            ind=len(m.group(1))
            while stack and stack[-1][0]>=ind: stack.pop()
            node=stack[-1][1] if stack else root
            v=m.group(3)
            if v=='': pend=m.group(2)
            else: node['attrs'].append((m.group(2),v)); pend=None
            continue
    return root

def attr(n,k,d=None):
    for a,v in n['attrs']:
        if a==k: return v
    return d
def kid(n,e):
    for a,c in n['kids']:
        if a==e: return c
    return None
def valtag(n):
    for k,v in n['attrs']:
        if k in VALTAGS: return f'{k}={v}'
    return 'noval'
def span(n):
    m=re.search(r'line:(\d+:\d+), endln:(\d+:\d+)', n['hdr'])
    return f'{m.group(1)}-{m.group(2)}' if m else '?'
def fileof(n):
    m=re.search(r'file:([^,]*)', n['hdr'])
    return os.path.basename(m.group(1)) if m else '?'
def nameof(n):
    m=re.match(r'([A-Za-z_0-9:$\.\[\]]*)\s*\(([^)]*)\)', n['hdr'])
    if m: return m.group(2) or m.group(1)
    return n['hdr'].split(',')[0].strip()
def tsdesc(n):
    if n is None: return 'TSnone'
    ts=kid(n,'vpiTypespec')
    if ts is None: return 'TS=none'
    act=kid(ts,'vpiActual')
    if act is None: return f'TS={ts["kind"]}->DANGLING'
    return f'TS={ts["kind"]}->{act["kind"]}'

def rhsdesc(n):
    if n is None: return 'RHS=<absent>'
    d=[f'RHS={n["kind"]}']
    for f in ('vpiDecompile','vpiSize','vpiConstType'):
        v=attr(n,f)
        d.append(f'{f}={v}' if v is not None else f'{f}=-')
    d.append(valtag(n)); d.append(tsdesc(n))
    return '|'.join(d)

# scopes whose names anchor the key
SCOPEK = ('package','module_inst','class_defn','function','task','gen_scope',
          'gen_scope_array','interface_inst','program','design','begin','named_begin')

def census(root, want=None):
    bag=collections.Counter()
    def walk(node, chain, depth, rootedge):
        nk=node['kind']
        newchain=chain
        if nk in SCOPEK:
            newchain = chain + [f'{nk}:{nameof(node)}']
        for e,c in node['kids']:
            re0 = rootedge if rootedge else (e or '')
            if c['kind']=='param_assign' and c['kids']:
                lhs=kid(c,'vpiLhs'); rhs=kid(c,'vpiRhs')
                lname = nameof(lhs) if lhs is not None else '?'
                if rhs is not None and rhs['kind']=='constant':
                    dec = attr(rhs,'vpiDecompile','')
                    if want is None or want(dec):
                        key='||'.join([re0, '/'.join(newchain[-3:]), span(c), lname])
                        pay=rhsdesc(rhs)+'##LHSTS='+ (tsdesc(lhs) if lhs is not None else '?')
                        bag[(key,pay)]+=1
            walk(c, newchain, depth+1, re0)
    walk(root, [], 0, '')
    return bag

UNSIZED=re.compile(r"^'[sS]?[bBoOhHdD]")
def isunsized(dec): return bool(UNSIZED.match(dec or ''))

def main():
    mode=os.environ.get('WANT','unsized')
    want = isunsized if mode=='unsized' else (None if mode=='all' else isunsized)
    G=census(parse(sys.argv[1]), want)
    O=census(parse(sys.argv[2]), want)
    label=sys.argv[3] if len(sys.argv)>3 else ''
    gk=collections.defaultdict(collections.Counter)
    ok=collections.defaultdict(collections.Counter)
    for (k,p),c in G.items(): gk[k][p]+=c
    for (k,p),c in O.items(): ok[k][p]+=c
    keys=set(gk)|set(ok)
    agree=dis=gonly=oonly=0
    rows=[]
    for k in sorted(keys):
        if k not in gk: oonly+=sum(ok[k].values()); rows.append(('OURS-ONLY',k,'',str(dict(ok[k])))); continue
        if k not in ok: gonly+=sum(gk[k].values()); rows.append(('GOLD-ONLY',k,str(dict(gk[k])),'')); continue
        if gk[k]==ok[k]: agree+=sum(gk[k].values())
        else:
            dis+=1; rows.append(('DIFFER',k,str(dict(gk[k])),str(dict(ok[k]))))
    print(f'CENSUS {label}: cells_golden={sum(sum(v.values()) for v in gk.values())} cells_ours={sum(sum(v.values()) for v in ok.values())} AGREE_KEYS={agree} DIFFER_KEYS={dis} GOLD_ONLY={gonly} OURS_ONLY={oonly}')
    for t,k,a,b in rows:
        print(f'  {t} {k}\n      G {a}\n      O {b}')
main()
