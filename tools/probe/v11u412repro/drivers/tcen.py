import os,sys,collections
d=sys.argv[1]; wd=sys.argv[2]
cnt=collections.Counter(); rows=collections.defaultdict(set)
for f in os.listdir(d):
    L=open(os.path.join(d,f),errors='ignore').read().splitlines()
    if not L: continue
    out=L[0][4:] if L[0].startswith('OUT ') else '?'
    rel=out.replace(wd+'/','')
    st=rel.split('/')[0]
    if st=='svtests': row='/'.join(rel.split('/')[2:-1])
    else: row='/'.join(rel.split('/')[1:-1])
    for l in L[1:]:
        law=l.split()[0] if l.split() else ''
        cnt[(st,law)]+=1; rows[(st,law)].add(row)
for k in sorted(cnt): print(k[0],k[1],cnt[k],'rows',len(rows[k]))
if len(sys.argv)>3:
    import json; json.dump({f'{k[0]}|{k[1]}':sorted(v) for k,v in rows.items()},open(sys.argv[3],'w'),indent=0)
