import sys,re
f=sys.argv[1]; pat=sys.argv[2]; k=int(sys.argv[3]) if len(sys.argv)>3 else 3
R=[]
for line in open(f):
    line=line.rstrip('\n')
    if re.match(r'^\d+\t',line): R.append(line)
    elif R: R[-1]+='\\n'+line
for i,r in enumerate(R):
    if re.search(pat,r):
        print('#%d %s'%(i,r))
        for j in range(1,k+1):
            if i+j<len(R): print('   #%d %s'%(i+j,R[i+j]))
