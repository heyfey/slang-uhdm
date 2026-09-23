#!/usr/bin/env python3
"""v11u116_cells.py <out-root> [arm...] — per-cell scorer over ALL located objects.
Cell key = (section, line, col, endline, endcol); value = sorted multiset of
compare-visible shapes (kind, name, value, size, decompile, const type, op type,
actual kind + actual's own KEEP fields, typespec actual kind). Parent/fullname out.
Prints per arm the cells where pris != law, classified TO/AWAY/OTHER/SAME-WRONG."""
import sys, os, re, subprocess
DUMP='/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump'
KEEP=re.compile(r'^\|(UINT|INT|BIN|HEX|DEC|OCT|STRING|vpiSize|vpiName|vpiDecompile|vpiConstType|vpiOpType|vpiNetDeclAssign|vpiDefName)')
SECS=(('|uhdmallModules','DEF'),('|uhdmtopModules','TOP'),('|uhdmallPackages','PKGDEF'),('|uhdmtopPackages','PKGTOP'),('\\_weaklyReferenced','WEAK'))
HDR=re.compile(r'^(\s*)\\_(\w+): (.*?)(?:, id:\d+)?(?:, file:[^,]*)?, line:(\d+):(\d+), endln:(\d+):(\d+)')
ANY=re.compile(r'^(\s*)\\_(\w+):')
def dump(u):
    t=u+'.dump'
    if not os.path.exists(t) or os.path.getmtime(t)<os.path.getmtime(u):
        with open(t,'w') as f: subprocess.run([DUMP,u],stdout=f,stderr=subprocess.STDOUT,timeout=300)
    return open(t,errors='replace').read().split('\n')
def ind(s): return len(s)-len(s.lstrip())
def subfields(L,j,base):
    # fields of the object whose header is at L[j], its own props at base+2
    out=[]; k=j+1
    while k<len(L) and ind(L[k])>base:
        st=L[k].strip()
        if ind(L[k])==base+2 and KEEP.match(st): out.append(st)
        k+=1
    return out
def objs(L):
    sec='HDR'; out={}
    for i,l in enumerate(L):
        for k,v in SECS:
            if l.startswith(k): sec=v
        if sec=='WEAK': break
        m=HDR.match(l)
        if not m: continue
        if i>0 and L[i-1].strip() in ('|vpiParent:','|vpiInstance:','|vpiModule:'): continue
        if i>0 and L[i-1].strip()=='|vpiActual:' and m.group(2).endswith('_typespec'): continue
        base=ind(l); kind=m.group(2); props=[]; j=i+1
        while j<len(L) and ind(L[j])>base:
            s=L[j]; st=s.strip()
            if ind(s)==base+2 and KEEP.match(st): props.append(st)
            if ind(s)==base+2 and st in ('|vpiActual:','|vpiTypespec:') and j+1<len(L):
                mm=ANY.match(L[j+1]); nk=mm.group(2) if mm else '?'
                tag=st[1:-1]+'='+nk
                if st=='|vpiActual:' and nk in ('enum_const','constant'):
                    tag+='('+' '.join(subfields(L,j+1,ind(L[j+1])))+')'
                if st=='|vpiTypespec:':
                    k=j+2
                    while k<len(L) and ind(L[k])>=ind(s)+2:
                        if L[k].strip()=='|vpiActual:' and ind(L[k])==ind(s)+2:
                            mm=ANY.match(L[k+1]); tag+='>'+(mm.group(2) if mm else '?'); break
                        k+=1
                props.append(tag)
            j+=1
        key=(sec,)+tuple(int(x) for x in m.group(4,5,6,7))
        out.setdefault(key,[]).append('%s{%s}'%(kind,' '.join(props)))
    return {k:sorted(v) for k,v in out.items()}
root=sys.argv[1]; arms=sys.argv[2:] or sorted(os.listdir(root))
T={'TO':0,'AWAY':0,'OTHER':0,'PARTIAL':0}
for arm in arms:
    w=os.path.join(root,arm)
    if not all(os.path.exists(os.path.join(w,x+'.uhdm')) for x in ('gold','pris','law')): continue
    import filecmp
    if filecmp.cmp(os.path.join(w,'pris.uhdm'),os.path.join(w,'law.uhdm'),shallow=False): continue
    G,P,Lw=(objs(dump(os.path.join(w,x+'.uhdm'))) for x in ('gold','pris','law'))
    for key in sorted(set(P)|set(Lw)):
        p=P.get(key,[]); l=Lw.get(key,[]); g=G.get(key,[])
        if p==l: continue
        if l==g: c='TO'
        elif p==g: c='AWAY'
        else:
            # partial: multiset distance to golden
            from collections import Counter
            dp=sum(((Counter(p)-Counter(g))+(Counter(g)-Counter(p))).values())
            dl=sum(((Counter(l)-Counter(g))+(Counter(g)-Counter(l))).values())
            if len(p)==len(l)==len(g):
                fd=lambda a,b:sum(len(set(x.split(' '))^set(y.split(' '))) for x,y in zip(a,b))
                dp,dl=fd(p,g),fd(l,g)
            c='PARTIAL' if dl<dp else ('OTHER' if dl==dp else 'AWAY')
        T[c]+=1
        print('%s %s %s:%d:%d-%d:%d'%(c,arm,key[0],*key[1:]))
        if c!='TO' or os.environ.get('V'):
            sh=lambda x:' ; '.join(sorted(set(x)))[:400]
            print('    G: '+sh(g)); print('    P: '+sh(p)); print('    L: '+sh(l))
print('TOTAL',T)
