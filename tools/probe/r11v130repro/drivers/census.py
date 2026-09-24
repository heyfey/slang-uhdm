# census.py <wdA> <wdB>  : row-by-row strict column, both corpora both modes; per-field counts for every changed row
import csv, sys, os, re, subprocess, glob
SC='/tmp/v11u130_bin/strictcmp'
A,B=sys.argv[1],sys.argv[2]
def load(p):
    d={}
    for r in csv.reader(open(p)):
        if r[0]=='name': continue
        d[(r[0],r[1])]=r
    return d
def parse(s):
    if s=='equal': return ('equal',0)
    m=re.match(r'differ:(\w+)\((\d+)\)',s)
    return (m.group(1),int(m.group(2))) if m else (s,-1)
def dbs(wd,corp,name,mode):
    ds=glob.glob(f'{wd}/{corp}/{mode}/{name}-*/cmds.txt')
    for c in ds:
        t=open(c).read()
        g=re.search(r'golden cache hit (\S+)\)',t)
        gold=os.path.join(g.group(1),'golden.uhdm') if g else None
        if gold is None:
            gg=glob.glob(os.path.dirname(c)+'/*surelog*.uhdm')+glob.glob(os.path.dirname(c)+'/golden.uhdm')
            gold=gg[0] if gg else None
        return gold, os.path.dirname(c)+'/slang.uhdm'
    return None,None
def fields(gold,ours):
    r=subprocess.run([SC,'--max','0',gold,ours],capture_output=True,text=True,timeout=1200)
    for l in (r.stdout+r.stderr).splitlines():
        if l.startswith('fields:'):
            return dict((kv.split("=")[0],int(kv.split("=")[1])) for kv in l[7:].split() if "=" in kv) | ({"DIVERGED":1} if "diverged" in l else {})
    return {}
tot={}
for corp in ('surelog','uhdm2rtlil'):
    a=load(f'{A}/{corp}.csv'); b=load(f'{B}/{corp}.csv')
    for k in sorted(set(a)|set(b)):
        ra=a.get(k); rb=b.get(k)
        if not ra or not rb: print('MISSING',corp,k); continue
        if ra[2]!=rb[2]: print('STATUS',corp,k,ra[2],rb[2]); tot['status']=tot.get('status',0)+1; continue
        if ra[2]!='CMP_EQUAL' or ra[5]==rb[5]: continue
        fa,ca=parse(ra[5]); fb,cb=parse(rb[5])
        if fb=='equal': cls='turned'
        elif fa=='equal': cls='WORSE'
        elif fa==fb: cls='fewer' if cb<ca else 'MORE'
        else: cls='moved'
        extra=''
        if cls not in ('turned',):
            ga,oa=dbs(A,corp,*k); gb,ob=dbs(B,corp,*k)
            pa=fields(ga,oa); pb=fields(gb,ob)
            grow=[f for f in pb if f not in ('objects_differing',) and pb[f]>pa.get(f,0)]
            extra=f' P{pa} X{pb}' + (f' GROW{grow}' if grow else ' nogrow')
            if grow: cls=cls+'-GROW'
        tot[cls]=tot.get(cls,0)+1
        print(f'{cls}\t{corp}\t{k[0]},{k[1]}\t{ra[5]} -> {rb[5]}{extra}')
print('TOTAL',tot)
