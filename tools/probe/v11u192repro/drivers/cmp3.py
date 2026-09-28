import sys,subprocess,re,os
def rd(f):
    d={}
    for l in open(f):
        t=l.split(); 
        if len(t)<3: continue
        kv={x.split('=')[0]:x.split('=',1)[1] for x in t[2:] if '=' in x}
        kv['raw']=' '.join(t[2:]); d[t[0]]=kv
    return d
P=rd(sys.argv[1]); X=rd(sys.argv[2]); tagX=sys.argv[3]
G='/tmp/v11u192_g'
brk=0; conv=0; lost=0
for k in sorted(P):
    p=P[k]; x=X.get(k)
    if not x: print('MISSING',k); continue
    ps=p.get('strict','SLANG_FAIL' if 'SLANG_FAIL' in p['raw'] else p['raw']); xs=x.get('strict','SLANG_FAIL' if 'SLANG_FAIL' in x['raw'] else x['raw'])
    if p.get('cmplines')!=x.get('cmplines'): print('CMPCHANGE',k,p.get('cmplines'),x.get('cmplines'))
    pe=ps.startswith('STRICT_EQUAL'); xe=xs.startswith('STRICT_EQUAL')
    if pe and not xe: brk+=1; print('BREAK',k,ps,'->',xs,x.get('fires'))
    elif xe and not pe: conv+=1
    elif not pe and not xe and p.get('md5')!=x.get('md5') and ps.startswith('STRICT_NOTEQUAL'):
        out=subprocess.run(['python3','/tmp/v11u192_drv/recdir.py',f'{G}/{k}/{sys.argv[4] if len(sys.argv)>4 else "P2"}.strict',f'{G}/{k}/{tagX}.strict'],capture_output=True,text=True).stdout
        if ' new=0 ' not in out.split('\n')[0] or 'CHG' in out: print('NEWWRONG',k,out.split('\n')[0]); 
print(f'{tagX}: case-modes={len(P)} conversions={conv} breaks={brk}')
