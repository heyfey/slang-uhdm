# v11u298 gridcmp.py <grid3 out> [<implementer grid.txt>]: law/fix movers, STRICT_EQUAL entries/exits, switch checks (R11U298_OFF on law and fix = pristine, R11V298_OFF on fix = law), and a verdict comparison with another grid.
import collections, sys
def load(f):
    rows=collections.defaultdict(dict)
    for l in open(f):
        w=l.split(); rows[(w[0],w[1])][w[2]]=' '.join(w[3:])
    return rows
md=lambda x:x.split('md5=')[1] if 'md5=' in x else x
st=lambda x:x.rsplit(' md5',1)[0]
mine=load(sys.argv[1])
if len(sys.argv)>2:
    theirs=load(sys.argv[2]); diffv=diffm=0; n=0
    for k in theirs:
        for lab in theirs[k]:
            if lab not in mine[k]: continue
            n+=1
            if st(theirs[k][lab])!=st(mine[k][lab]): diffv+=1; print('VERDICT DIFF',k,lab,theirs[k][lab],'|',mine[k][lab])
            elif md(theirs[k][lab])!=md(mine[k][lab]): diffm+=1
    print('compared',n,'verdict diffs',diffv,'md5-only diffs',diffm)
movers=enter=leave=fmov=fenter=fleave=0; bad=[]
for k in sorted(mine):
    r=mine[k]
    if md(r['law+R11U298_OFF'])!=md(r['pristine']): bad.append(('lawOFF',k))
    if md(r['fix+R11U298_OFF'])!=md(r['pristine']): bad.append(('fixUOFF',k))
    if md(r['fix+R11V298_OFF'])!=md(r['law']): bad.append(('fixVOFF',k))
    if md(r['fix'])!=md(r['law']): print('FIX!=LAW',k,st(r['pristine']),'|',st(r['law']),'|',st(r['fix']))
    for a,b,c in (('law','movers',0),('fix','fmovers',1)):
        if md(r['pristine'])!=md(r[a]):
            if c==0: movers+=1
            else: fmov+=1
            e='STRICT_EQUAL' in r[a] and 'STRICT_EQUAL' not in r['pristine']; lv='STRICT_EQUAL' in r['pristine'] and 'STRICT_EQUAL' not in r[a]
            if c==0: enter+=e; leave+=lv
            else: fenter+=e; fleave+=lv
            if r['pristine'].split()[0]!=r[a].split()[0]: print('RC CHANGE',a,k)
print('views',len(mine),'law movers',movers,'enter',enter,'leave',leave,'| fix movers',fmov,'enter',fenter,'leave',fleave,'| bad',bad)
