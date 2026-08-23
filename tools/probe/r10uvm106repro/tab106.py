#!/usr/bin/env python3
import re, sys, subprocess, collections, os
DUMP = "/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump"
OBJ = re.compile(r'^(\s*)\\_([A-Za-z_0-9]+): ?(.*)$')
ATTR = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')
VALTAGS = ('BIN','OCT','HEX','INT','UINT','DEC','REAL','STRING','SCAL','TIME')
def lines_of(p):
    if p.endswith('.dump'): return open(p,errors='replace').read().split('\n')
    return subprocess.run([DUMP,p],capture_output=True,text=True).stdout.split('\n')
def parse(p):
    root={'kind':'ROOT','hdr':'','attrs':[],'kids':[]}; stack=[(-1,root)]; pend=None
    for ln in lines_of(p):
        m=OBJ.match(ln)
        if m:
            ind=len(m.group(1)); node={'kind':m.group(2),'hdr':m.group(3),'attrs':[],'kids':[]}
            while stack and stack[-1][0]>=ind: stack.pop()
            (stack[-1][1] if stack else root)['kids'].append((pend,node)); pend=None
            stack.append((ind,node)); continue
        m=ATTR.match(ln)
        if m:
            ind=len(m.group(1))
            while stack and stack[-1][0]>=ind: stack.pop()
            node=stack[-1][1] if stack else root; v=m.group(3)
            if v=='': pend=m.group(2)
            else: node['attrs'].append((m.group(2),v)); pend=None
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
        if k in VALTAGS: return f'{k}:{v}'
    return '-'
def span(n):
    m=re.search(r'line:(\d+:\d+), endln:(\d+:\d+)',n['hdr'])
    return f'{m.group(1)}-{m.group(2)}' if m else '?'
def nameof(n):
    m=re.match(r'([A-Za-z_0-9:$@\.\[\]]*)\s*\(([^)]*)\)',n['hdr'])
    if m: return m.group(2) or m.group(1)
    return n['hdr'].split(',')[0].strip()
def tsd(n):
    if n is None: return '?'
    ts=kid(n,'vpiTypespec')
    if ts is None: return 'none'
    act=kid(ts,'vpiActual')
    return 'DANGLING' if act is None else act['kind'].replace('_typespec','_ts')
SCOPEK=('package','module_inst','class_defn','function','task','gen_scope','gen_scope_array',
        'interface_inst','program','design','begin','named_begin','class_typespec')
def cells(root):
    out=collections.Counter()
    def walk(n,chain,redge):
        for e,c in n['kids']:
            r2=redge if redge else (e or '')
            ch=chain
            if c['kind'] in SCOPEK: ch=chain+[nameof(c)]
            if c['kind']=='param_assign' and c['kids']:
                lhs=kid(c,'vpiLhs'); rhs=kid(c,'vpiRhs')
                ln=nameof(lhs) if lhs is not None else '?'
                ln=ln.split('::')[-1].split('.')[-1]
                key=(r2,'/'.join(ch[-2:]),ln)
                if rhs is None: pay='RHS=absent'
                elif rhs['kind']!='constant': pay=f'RHS={rhs["kind"]}'
                else: pay=f'sz={attr(rhs,"vpiSize","-")} ct={attr(rhs,"vpiConstType","-")} {valtag(rhs)} dec={attr(rhs,"vpiDecompile","-")} ts={tsd(rhs)}'
                if os.environ.get('PROJ')=='szts' and rhs is not None and rhs['kind']=='constant':
                    pay=f'sz={attr(rhs,"vpiSize","-")} ts={tsd(rhs)}'
                else:
                    pay+=f'  [Lts={tsd(lhs)}]'
                out[(key,pay)]+=1
            walk(c,ch,r2)
    walk(root,[],'')
    return out
def main():
    G=cells(parse(sys.argv[1])); O=cells(parse(sys.argv[2])) if sys.argv[2]!='-' else collections.Counter()
    lab=sys.argv[3] if len(sys.argv)>3 else ''
    gk=collections.defaultdict(collections.Counter); ok=collections.defaultdict(collections.Counter)
    for (k,p),c in G.items(): gk[k][p]+=c
    for (k,p),c in O.items(): ok[k][p]+=c
    for k in sorted(set(gk)|set(ok)):
        g=' ; '.join(f'{p} x{c}' for p,c in sorted(gk[k].items()))
        o=' ; '.join(f'{p} x{c}' for p,c in sorted(ok[k].items()))
        st='SAME' if gk[k]==ok[k] else 'DIFF'
        print(f'{lab} {st} {k[0]}|{k[1]}|{k[2]}\n    G {g}\n    O {o}')
main()
