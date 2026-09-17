#!/usr/bin/env python3
"""Like shape.py, but reports the op-level vpiTypespec REF's OWN NAME (the
field shape.py does not read) per param_assign cell."""
import re, sys
def ind(l): return len(l) - len(l.lstrip())
def block(lines, i, base):
    out=[]
    while i < len(lines):
        l=lines[i]
        if l.strip() and ind(l) <= base: break
        out.append(l); i+=1
    return out,i
def parse(path):
    lines=open(path,errors='replace').read().splitlines()
    sect=None;out=[];i=0
    while i<len(lines):
        ln=lines[i]
        m=re.match(r'^\|(uhdm\w+):',ln)
        if m: sect=m.group(1); i+=1; continue
        m=re.match(r'^(\s*)\\_param_assign: , (line:[\d:]+)',ln)
        if not m: i+=1; continue
        pind=ind(ln); loc=m.group(2)
        blk,i=block(lines,i+1,pind)
        name='?';rhs=None;label=None
        for a,l in enumerate(blk):
            if ind(l)!=pind+2: continue
            s=l.lstrip()
            if s.startswith('|'): label=s.split(':',1)[0]; continue
            if s.startswith('\\_') and label=='|vpiLhs':
                mm=re.search(r'\\_parameter: \(([^)]*)\)',s)
                if mm: name=mm.group(1)
            if s.startswith('\\_') and label=='|vpiRhs': rhs=a
        if rhs is None or not blk[rhs].lstrip().startswith('\\_operation:'): continue
        rind=ind(blk[rhs]); rblk,_=block(blk,rhs+1,rind)
        ts='NONE';label=None
        for a,l in enumerate(rblk):
            if ind(l)!=rind+2: continue
            s=l.lstrip()
            if s.startswith('|'): label=s.split(':',1)[0]; continue
            if s.startswith('\\_') and label=='|vpiTypespec':
                mm=re.match(r'\\_ref_typespec: (\(([^)]*)\))?',s)
                ts = ('BARE' if not (mm and mm.group(2)) else mm.group(2)) if mm else 'OTHER'
        out.append((sect,name,loc,ts))
    return out
if __name__=='__main__':
    import collections
    ds=[dict(((a,b,c),d) for a,b,c,d in parse(p)) for p in sys.argv[1:]]
    keys=sorted(set().union(*[set(d) for d in ds]))
    cnt=collections.Counter()
    for k in keys:
        vs=[d.get(k,'-') for d in ds]
        if len(set(vs))>1:
            cnt[tuple(vs)]+=1
    for t,c in cnt.most_common(20): print('%5d  %s' % (c,' | '.join(t)))
    print('cells: %s' % ' '.join(str(len(d)) for d in ds))
