import os,re,csv,sys
pat=re.compile(r'\{\s*(<<|>>)\s*([A-Za-z_][A-Za-z0-9_:$]*)\s*\{')
KW={'byte':8,'shortint':16,'int':32,'integer':32,'longint':64,'bit':1,'logic':1,'reg':1}
BITS={'time','realtime','real','shortreal'}
roots={'/home/heyfey/git-repos/Surelog/tests':1,
       '/home/heyfey/git-repos/Surelog/third_party/tests':1}
status={}
for r in csv.DictReader(open('/tmp/wt_v93/results/golden_surelog.csv')):
    status.setdefault(r['name'],{})[r['mode']]=r['status']
def testname(p):
    for root in roots:
        if p.startswith(root+'/'):
            return p[len(root)+1:].split('/')[0]
    return None
agg={}
for root in list(roots)+['/home/heyfey/git-repos/sv-tests/third_party/tools/Surelog/third_party/UVM']:
    for dp,dn,fn in os.walk(root):
        for f in fn:
            if not f.endswith(('.sv','.svh','.v','.vh')): continue
            p=os.path.join(dp,f)
            try: t=open(p,errors='replace').read()
            except Exception: continue
            ms=[m.group(2) for m in pat.finditer(t)]
            ms=[x for x in ms if not x.isdigit()]
            if not ms: continue
            tn=testname(p) or 'UVM-TREE'
            d=agg.setdefault(tn,{'files':set(),'toks':{}})
            d['files'].add(p)
            for x in ms: d['toks'][x]=d['toks'].get(x,0)+1
print(f"{'test':28s} {'default':14s} {'testflags':14s} toks")
for tn in sorted(agg):
    st=status.get(tn,{})
    print(f"{tn:28s} {st.get('default','-'):14s} {st.get('testflags','-'):14s} {dict(sorted(agg[tn]['toks'].items(),key=lambda kv:-kv[1])[:6])}")
