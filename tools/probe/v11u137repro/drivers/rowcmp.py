import sys,subprocess,os
SC=os.environ['STRICT_CMP']
g,p,l,tag=sys.argv[1:5]
w='/tmp/v11u137_rc/'+tag; os.makedirs(w,exist_ok=True)
for t,f in (('P',p),('L',l)):
    subprocess.run([SC,'--max','1000000','--dump-a',w+'/A.rec','--dump-b',w+'/'+t+'.rec',g,f],capture_output=True)
A=open(w+'/A.rec').read().splitlines()
R={t:open(w+'/'+t+'.rec').read().splitlines() for t in 'PL'}
def firstdiv(B):
    for i in range(min(len(A),len(B))):
        a=A[i].split('\t'); b=B[i].split('\t')
        if a[:2]!=b[:2]: return i
    return min(len(A),len(B)) if len(A)!=len(B) else None
fd={t:firstdiv(R[t]) for t in 'PL'}
print(tag,'lenA',len(A),'lenP',len(R['P']),'lenL',len(R['L']),'firstdiv',fd)
lim=min(x for x in [fd['P'],fd['L'],len(A)] if x is not None)
newbad=[i for i in range(lim) if A[i]==R['P'][i] and A[i]!=R['L'][i]]
fixed=[i for i in range(lim) if A[i]!=R['P'][i] and A[i]==R['L'][i]]
print(' before common divergence',lim,': newly differing',len(newbad),'fixed',len(fixed))
for i in newbad[:8]:
    print('  #',i,'\n   A',A[i],'\n   P',R['P'][i],'\n   L',R['L'][i])
