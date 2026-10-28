import sys,re
f=sys.argv[1]; n=int(sys.argv[2])  # n = record index (0-based like strictcmp #)
R=[]
for line in open(f):
    line=line.rstrip('\n')
    if re.match(r'^\d+\t',line): R.append(line)
    elif R: R[-1]+='\\n'+line
d=int(R[n].split('\t')[0]); out=['#%d %s'%(n,R[n])]
for i in range(n-1,-1,-1):
    dd=int(R[i].split('\t')[0])
    if dd<d: out.append('#%d %s'%(i,R[i])); d=dd
    if d==0: break
print('\n'.join(reversed(out)))
