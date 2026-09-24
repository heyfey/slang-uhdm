import json,sys,collections
sys.path.insert(0,'/tmp/wt_r11u128/tools/probe/r11u128map/drivers')
from analyze import load, parents
R=[json.loads(l) for l in open('corpus.jsonl')]
want={'struct|golden-only:fewer-copies|logic_net|under:ref_obj','struct|golden-only:elsewhere|logic_net|under:ref_obj','struct|ours-only:fewer-copies|logic_net|under:ref_obj','struct|ours-only:elsewhere|logic_net|under:ref_obj'}
stat=collections.Counter()
for r in R:
  xs=[x for x in r['rows'] if x['cluster'] in want]
  if not xs: continue
  D=f"/tmp/r11u128_dumps/{r['corpus']}/{r['mode']}/{r['test']}"
  A,B=load(D+'.a'),load(D+'.b')
  for x in xs:
    side='golden' if x['ia']>=0 else 'ours'; S=A if side=='golden' else B; i=x['ia'] if side=='golden' else x['ib']
    rec=S[i]; kids = i+1<len(S) and int(S[i+1][0])>int(rec[0])
    earlier=[j for j in range(i) if S[j][1:]==rec[1:]]
    # typespec child on the earlier identical record?
    ek=[ (j+1<len(S) and int(S[j+1][0])>int(S[j][0])) for j in earlier]
    stat[(x['cluster'].split('|')[1],'haschildren' if kids else 'nochildren','earlier-identical=%d'%len(earlier),'earlier-with-children=%d'%sum(ek))]+=1
for k,v in stat.most_common(): print(v,k)
