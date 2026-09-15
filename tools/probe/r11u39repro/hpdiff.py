import re,sys,difflib
def blocks(f):
    L=open(f,errors='replace').read().split('\n'); i=0; out={}
    while i<len(L):
        m=re.match(r'^(\s*)(?:\\_)?hier_path: \((.*)\), ',L[i])
        if m:
            ind=len(m.group(1)); j=i+1; blk=[L[i]]
            while j<len(L):
                if L[j].strip()=='': break
                if len(L[j])-len(L[j].lstrip())<=ind: break
                blk.append(L[j]); j+=1
            out.setdefault(m.group(2),[]).append('\n'.join(x.strip() for x in blk))
            i=j
        else: i+=1
    return out
g=blocks(sys.argv[1]); o=blocks(sys.argv[2])
for k in sorted(set(g)|set(o)):
    gb=sorted(g.get(k,[])); ob=sorted(o.get(k,[]))
    if gb==ob: print("SAME  "+k); continue
    print("DIFF  "+k)
    for a,b in zip(gb+['']*9, ob+['']*9):
        if a==b or (not a and not b): continue
        for l in difflib.unified_diff(a.split('\n'),b.split('\n'),lineterm='',n=0):
            if l.startswith(('---','+++','@@')): continue
            print("   "+l)
        break
