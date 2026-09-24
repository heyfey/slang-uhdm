import json,collections,csv,os,re
R=[json.loads(l) for l in open('/tmp/r11u122_work/all4.jsonl')]
strict={}
for c in ['surelog','uhdm2rtlil']:
    for r in csv.DictReader(open(f'/tmp/strict_sweep/{c}.csv')):
        strict[(c,r['mode'],r['name'])]=r['strict']
TSISH=lambda t: t.endswith('_typespec') or t in ('range','typespec_member')
def family(x):
    c=x['cluster']; p=c.split('|'); f=x['facet']; t=x['type']
    if f=='struct':
        side,how=p[1].split(':'); side=side.replace('-only','')
        if how=='absent': return f'STRUCT-ABSENT|{side}|{t}'
        if side=='golden' and t=='parameter' and 'under:param_assign' in c: return 'STRUCT-IMPPARAM-CLONE|golden'
        if TSISH(t): return f'STRUCT-TSCOPY|{side}'
        return f'STRUCT-SHARE|{side}|{t}'
    if f in ('depth','order'): return 'WALK-DEPTH-ORDER'
    if f=='fullname':
        if t=='ref_typespec' or '_typespec' in x['chain']: return 'FULLNAME-IN-TYPESPEC-SUBTREE'
        sh=p[2].split(':')[0]
        return f'FULLNAME|{t}|{sh}'
    if f=='file':
        if 'other-file' in p[2]: return 'FILE-OTHER-BUFFER'
        return ('FILE-EMPTY|' if p[2]=='ours-empty' else 'FILE-EXTRA|')+t
    if f=='span': return f'SPAN|{t}'
    if f=='value': return f'VALUE|{t}|{p[2]}'
    if f=='name': return f'NAME|{t}'
    return c
rowsC=collections.defaultdict(set); rowsF=collections.defaultdict(set)
objC=collections.Counter(); objF=collections.Counter(); rcC=collections.defaultdict(set); rcF=collections.defaultdict(set)
rowobj=collections.Counter(); ex={}; famOf={}
for r in R:
    key=(r['corpus'],r['mode'],r['test'])
    for x in r['rows']:
        c=x['cluster']; fm=family(x); n=x.get('nobj',1); famOf.setdefault(c,collections.Counter())[fm]+=1
        rowsC[key].add(c); rowsF[key].add(fm); objC[c]+=n; objF[fm]+=n; rcC[c].add(key); rcF[fm].add(key); rowobj[(key,c)]+=n
        cand=((r['nA'],len(r['rows'])),key,x)
        if c not in ex or cand[0]<ex[c][0]: ex[c]=cand
        if fm not in ex or cand[0]<ex[fm][0]: ex[fm]=cand
rankC=sorted(rcC,key=lambda c:(-len(rcC[c]),-objC[c],c))
rankF=sorted(rcF,key=lambda c:(-len(rcF[c]),-objF[c],c))
cid={c:'C%04d'%(i+1) for i,c in enumerate(rankC)}
fid={c:'F%02d'%(i+1) for i,c in enumerate(rankF)}
def yld(fixed,rows):
    return sum(1 for k,s in rows.items() if s<=fixed)
def tyld(fixed,rows):
    # tests (corpus,test) whose every NE mode becomes equal
    t=collections.defaultdict(list)
    for k,s in rows.items(): t[(k[0],k[2])].append(s<=fixed)
    return sum(1 for v in t.values() if all(v))
json.dump(dict(cid=cid,fid=fid,rankC=rankC[:80],rankF=rankF),open('/tmp/r11u122_work/ids.json','w'))
# outputs
os.makedirs('/tmp/r11u122_work/out',exist_ok=True)
with open('/tmp/r11u122_work/out/clusters.csv','w') as f:
    f.write('test,mode,corpus,first_field,cluster_id,objects\n')
    for key in sorted(rowsC):
        ff=strict[key].split(':',1)[1].split('(')[0]
        for c in sorted(rowsC[key],key=lambda c:cid[c]):
            f.write(f'{key[2]},{key[1]},{key[0]},{ff},{cid[c]},{rowobj[(key,c)]}\n')
with open('/tmp/r11u122_work/out/cluster_index.csv','w') as f:
    f.write('cluster_id,family_id,rows,rows_surelog,rows_uhdm2rtlil,tests,objects,alone_yield_rows,key,example\n')
    for c in rankC:
        e=ex[c]; x=e[2]; fm=famOf[c].most_common(1)[0][0]
        f.write(f"{cid[c]},{fid[fm]},{len(rcC[c])},{sum(1 for k in rcC[c] if k[0]=='surelog')},{sum(1 for k in rcC[c] if k[0]=='uhdm2rtlil')},{len({(k[0],k[2]) for k in rcC[c]})},{objC[c]},{yld({c},rowsC)},\"{c}\",\"{e[1][0]}/{e[1][1]}/{e[1][2]} #{x['ia']}/{x['ib']} {x['type']} {x['name']}\"\n")
with open('/tmp/r11u122_work/out/family_index.csv','w') as f:
    f.write('family_id,rows,rows_surelog,rows_uhdm2rtlil,tests,objects,alone_yield_rows,clusters,key,example\n')
    for fm in rankF:
        e=ex[fm]; x=e[2]; ncl=sum(1 for c in famOf if famOf[c].most_common(1)[0][0]==fm)
        f.write(f"{fid[fm]},{len(rcF[fm])},{sum(1 for k in rcF[fm] if k[0]=='surelog')},{sum(1 for k in rcF[fm] if k[0]=='uhdm2rtlil')},{len({(k[0],k[2]) for k in rcF[fm]})},{objF[fm]},{yld({fm},rowsF)},{ncl},\"{fm}\",\"{e[1][0]}/{e[1][1]}/{e[1][2]} #{x['ia']}/{x['ib']} {x['type']} {x['name']}\"\n")
# yield tables
print('ROWS',len(rowsC),'TESTS',len({(k[0],k[2]) for k in rowsC}))
print('== cluster yield (top 15 by rows): id rows objs alone cum cum_tests key')
cum=set()
for c in rankC[:15]:
    cum.add(c); print(cid[c],len(rcC[c]),objC[c],yld({c},rowsC),yld(cum,rowsC),tyld(cum,rowsC),c)
print('== family yield (top 15)')
cum=set()
for fm in rankF[:15]:
    cum.add(fm); print(fid[fm],len(rcF[fm]),objF[fm],yld({fm},rowsF),yld(cum,rowsF),tyld(cum,rowsF),fm)
print('all families:',len(rankF))
for fm in rankF[15:]: print(fid[fm],len(rcF[fm]),objF[fm],yld({fm},rowsF),fm)
# greedy best-yield families
print('== greedy by marginal yield (families)')
cum=set(); 
for i in range(15):
    best=max((f for f in rankF if f not in cum), key=lambda f:(yld(cum|{f},rowsF),len(rcF[f])))
    cum.add(best); print(i+1,fid[best],yld(cum,rowsF),tyld(cum,rowsF),best)
print('== combos')
allF=set(rankF)
def combo(name,pred):
    s={f for f in allF if pred(f)}
    print(f'{name}: families={len(s)} rows_touched={len(set().union(*[rcF[f] for f in s]))} yield_rows={yld(s,rowsF)} yield_tests={tyld(s,rowsF)}')
    return s
TS=combo('TYPESPEC-IDENTITY (tscopy both sides + fullname-in-ts-subtree + absent *_typespec + walk)', lambda f: f.startswith('STRUCT-TSCOPY') or f=='FULLNAME-IN-TYPESPEC-SUBTREE' or (f.startswith('STRUCT-ABSENT') and f.endswith(('_typespec','range'))) or f=='WALK-DEPTH-ORDER')
ST=combo('ALL STRUCT + WALK + FULLNAME-IN-TS', lambda f: f.startswith('STRUCT') or f=='WALK-DEPTH-ORDER' or f=='FULLNAME-IN-TYPESPEC-SUBTREE')
FE=combo('FILE-EMPTY (all kinds)', lambda f: f.startswith('FILE-EMPTY'))
FA=combo('ALL FILE (empty+extra+other-buffer)', lambda f: f.startswith('FILE'))
SP=combo('ALL SPAN', lambda f: f.startswith('SPAN'))
FN=combo('ALL FULLNAME', lambda f: f.startswith('FULLNAME'))
VA=combo('ALL VALUE+NAME', lambda f: f.startswith(('VALUE','NAME')))
for a,b,n in [(FA,ST,'FILE+STRUCT'),(FA|ST,FN,'FILE+STRUCT+FULLNAME'),(FA|ST|FN,SP,'FILE+STRUCT+FULLNAME+SPAN'),(FA|ST|FN|SP,VA,'everything')]:
    s=a|b; print(f'{n}: yield_rows={yld(s,rowsF)} yield_tests={tyld(s,rowsF)}')
# per-corpus breakdown for the file-only fix
for c in ['surelog','uhdm2rtlil']:
    sub={k:v for k,v in rowsF.items() if k[0]==c}
    print(c,'rows',len(sub),'FILE-EMPTY yield',yld(FE,sub),'ALL FILE',yld(FA,sub),'STRUCT',yld(ST,sub))
