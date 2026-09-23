import sys,re,collections
# For arm dir: find the member-value span (the concat after 'v: ' in IMPL line) and list, per dump,
# the multiset of (kind, size, value) objects at that exact span.
arm=sys.argv[1]; src=open(f'{sys.argv[2]}/{arm}/dut.sv').read().split('\n')
for ln,l in enumerate(src,1):
    if 'IMPL =' in l or 'ARR =' in l: break
c=l.index('v: ')+3
# match braces
d=0
for j in range(c,len(l)):
    if l[j]=='{': d+=1
    elif l[j]=='}':
        d-=1
        if d==0: e=j+1; break
span=f'line:{ln}:{c+1}, endln:{ln}:{e+1}'
def objs(p):
    L=open(p,errors='replace').read().split('\n'); out=collections.Counter()
    for i,x in enumerate(L):
        if span in x and re.match(r'\s*\\_(constant|operation):',x):
            ind=len(x)-len(x.lstrip()); kind=x.strip().split(':')[0][2:]; info=[]
            for y in L[i+1:i+30]:
                yi=len(y)-len(y.lstrip())
                if yi<=ind: break
                if yi==ind+2 and re.match(r'\s*\|(vpiSize|BIN|UINT|HEX|INT|vpiOpType|vpiDecompile):',y): info.append(y.strip())
            out[(kind,)+tuple(info)]+=1
    return out
for t in ('gold','pris','lawx'):
    print(arm,t,dict(objs(f'{arm}/{t}.dump')))
