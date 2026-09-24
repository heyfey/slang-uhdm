import sys, os, csv, re, subprocess
sys.path.insert(0, '/tmp/wt_v11u134/scripts')
os.environ.setdefault('STRICT_CMP', '/tmp/v11u134_bin/strictcmp')
import check_probe as cp
SC='/tmp/v11u134_bin/strictcmp'
def rows(p):
    return {r['case']: r for r in csv.DictReader(open(p))}
P=rows('/tmp/v11u134_wdP/probe.csv'); L=rows('/tmp/v11u134_wdL/probe.csv')
def fields(g,o):
    out=subprocess.run([SC,'--max','0',g,o],capture_output=True,text=True).stdout
    m=re.search(r'^fields: (.*)$',out,re.M)
    d={}
    if m:
        for k,v in re.findall(r'(\w+)=(\d+)',m.group(1)): d[k]=int(v)
    return d, ('walk diverged' in out)
n=0
for c in sorted(P):
    if P[c]['status']==L[c]['status'] and P[c]['strict']==L[c]['strict']: continue
    n+=1
    g,_=cp.golden(c,'/tmp/v11u134_scr/pg',300)
    fp,dp=fields(g,'/tmp/v11u134_wdP/probe/'+c.replace('/','__')+'.uhdm')
    fl,dl=fields(g,'/tmp/v11u134_wdL/probe/'+c.replace('/','__')+'.uhdm')
    grow={k:(fp.get(k,0),fl[k]) for k in fl if k!='objects_differing' and fl[k]>fp.get(k,0)}
    print(('GROW ' if grow else 'ok   ')+c, P[c]['strict'],'->',L[c]['strict'], grow if grow else '', 'div:%s->%s'%(dp,dl))
print('changed', n, file=sys.stderr)
