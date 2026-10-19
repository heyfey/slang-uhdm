import sys,subprocess,os
from concurrent.futures import ThreadPoolExecutor
CMP='/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp'
W=sys.argv[1]; paths=[l.strip() for l in open(sys.argv[2]) if l.strip()]
def one(p):
    w=os.path.join(W,p[:-3]); g=w+'/slpp_all/surelog.uhdm'; o=w+'/slang.uhdm'
    try: c=subprocess.run([CMP,g,o],capture_output=True,text=True,timeout=1200); t=(c.stderr+c.stdout).splitlines()
    except Exception as e: return p+' | ERR '+str(e)
    open(w+'/cmp.txt','w').write('\n'.join(t))
    if 'LHS:' not in t: return p+' | n='+str(len(t))
    i=t.index('LHS:'); return p+' | n=%d | '%len(t)+' / '.join(x.strip()[:110] for x in t[i+1:i+4])
with ThreadPoolExecutor(3) as ex:
    for r in ex.map(one,paths): print(r,flush=True)
