import sys,re,os,glob
# for each grid dir: parse pris.strict and law.strict records (#idx field + A/B lines); report entering records
def parse(f):
    recs={}; cur=None
    if not os.path.exists(f): return None
    for l in open(f):
        m=re.match(r'#(\d+) (\S+)',l)
        if m: cur=(int(m.group(1)),m.group(2)); recs[cur]=[]; continue
        if cur and l.startswith('  '): recs[cur].append(l.rstrip('\n'))
    return recs
for d in sorted(sys.argv[1:]):
    p=parse(d+'/pris.strict'); q=parse(d+'/law.strict')
    if p is None or q is None: continue
    ent=[k for k in q if k not in p or q[k]!=p[k]]
    left=[k for k in p if k not in q]
    fp=min(p) if p else None; fq=min(q) if q else None
    tail=lambda f: open(f).read().strip().splitlines()[-1] if os.path.exists(f) else ''
    flag = 'ENTER' if ent else ('same' if not left else 'improve')
    if ent or left:
        print(os.path.basename(d), flag, 'pris_first',fp,'law_first',fq,'enter',len(ent),'leave',len(left), '|', tail(d+'/pris.strict'),'->',tail(d+'/law.strict'))
        for k in ent[:4]:
            print('   ENTER',k, q[k])
