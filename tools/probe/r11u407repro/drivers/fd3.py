import csv,subprocess,os,re,sys
from concurrent.futures import ThreadPoolExecutor
CMP='/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp'
W=sys.argv[1]; paths=[l.strip() for l in open(sys.argv[2]) if l.strip()]; out=sys.argv[3]
def one(p):
    w=os.path.join(W,p[:-3]); g=os.path.join(w,'slpp_all','surelog.uhdm'); o=os.path.join(w,'slang.uhdm')
    if not(os.path.exists(g) and os.path.exists(o)): return [p,'missing','','','']
    if not os.path.exists(w+'/o.dump'): return [p,'nodump','','','']
    try: d=subprocess.run(['diff',w+'/g.dump',w+'/o.dump'],capture_output=True,text=True,timeout=120).stdout.splitlines()
    except subprocess.TimeoutExpired: d=['timeout']
    d2=[l for l in d if l[:1] in '<>']
    c=subprocess.run([CMP,g,o],capture_output=True,text=True,timeout=900)
    t=c.stderr+c.stdout
    lhs=t.split('LHS:')[1].strip().splitlines()[:3] if 'LHS:' in t else ['']
    return [p,str(len(d2)),d2[0][:150] if d2 else '',d2[1][:150] if len(d2)>1 else '',' / '.join(x.strip()[:80] for x in lhs)]
with ThreadPoolExecutor(4) as ex: rows=list(ex.map(one,paths))
wr=csv.writer(open(out,'w')); wr.writerow(['path','ndiff','d1','d2','cmp'])
for r in rows: wr.writerow(r)
