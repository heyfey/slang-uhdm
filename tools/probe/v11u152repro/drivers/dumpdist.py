#!/usr/bin/env python3
# dumpdist.py golden.uhdm pris.uhdm law.uhdm : order-blind multiset distance of uhdm-dump lines to golden
import subprocess, sys, re, collections, os
D=os.environ.get('UHDM_DUMP','/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump')
def dump(f):
    t=subprocess.run([D,f],capture_output=True,text=True,errors='replace').stdout
    out=[]
    for l in t.splitlines():
        l=re.sub(r'/[^ ,:()]*/','',l)       # normalise directories
        l=re.sub(r'id:\d+','',l)
        out.append(l.strip())
    return collections.Counter(out)
g,p,l=(dump(x) for x in sys.argv[1:4])
def dist(a,b): return sum(((a-b)+(b-a)).values())
dp,dl=dist(g,p),dist(g,l)
tag='CLOSER' if dl<dp else ('SAME' if dl==dp else 'AWAY')
# lines law adds that golden lacks and pristine did not have
new_bad=((l-g)-(p-g))
print(f'{tag} pris={dp} law={dl} newbad={sum(new_bad.values())}')
if len(sys.argv)>4:
    for k,v in list(new_bad.items())[:int(sys.argv[4])]: print('  +',v,k)
    gone_good=((g-l)-(g-p))
    for k,v in list(gone_good.items())[:int(sys.argv[4])]: print('  -',v,k)
