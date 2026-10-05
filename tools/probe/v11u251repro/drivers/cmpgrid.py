# (v11u251) cmpgrid.py <gridA> <gridB>: two grid files compared line by line on cmp, cmplines, strict and rc, and per case on the pattern of which configurations write pristine bytes and which the law's (database md5s embed the worktree path, so md5s are not compared directly).
import sys
def load(f):
    d={}
    for l in open(f):
        x=l.split(); k=(x[0],x[1]); kv=dict(t.split('=',1) for t in x[2:] if '=' in t); d[k]=kv
    return d
A=load(sys.argv[1]); Bd=load(sys.argv[2])
bad=0
cases=sorted(set(k[0] for k in A))
for c in cases:
    ta=[k for k in A if k[0]==c]
    def pat(D):
        p=D.get((c,'pristine'),{}).get('md5'); L=D.get((c,'law'),{}).get('md5')
        return {k[1]:('P' if D[k].get('md5')==p else 'L' if D[k].get('md5')==L else 'X') for k in D if k[0]==c}
    for k in ta:
        a=A[k]; b=Bd.get(k,{})
        if {x:a.get(x) for x in ('cmp','cmplines','strict','rc')}!={x:b.get(x) for x in ('cmp','cmplines','strict','rc')}:
            bad+=1; print('FIELD',k,a,b)
    if pat(A)!=pat(Bd): bad+=1; print('PATTERN',c,pat(A),pat(Bd))
print('lines',len(A),len(Bd),'mismatch',bad)
