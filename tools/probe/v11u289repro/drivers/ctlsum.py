# v11u289: P->L, P->F, L->F mover census of controls.sh / vgridf.sh outputs.
import sys,collections
r=collections.defaultdict(dict)
for f in sys.argv[1:]:
    for l in open(f):
        p=l.split(); fl={}
        for x in p[3:]:
            if '=' in x: k,v=x.split('=',1); fl[k]=v
        if p[2] in('SURELOG_FAIL','SLANG_FAIL'): fl['strict']=p[2]; fl['md5']=p[2]; fl['rc']=p[3].split('=')[1]; fl['cmplines']='-'
        r[p[1]][p[0]]=fl
def eq(s): return s.get('strict','').startswith('STRICT_EQUAL')
for a,b in (('P','L'),('P','F'),('L','F')):
    mv=[k for k,d in r.items() if d[a].get('md5')!=d[b].get('md5')]
    ent=[k for k in mv if eq(r[k][b]) and not eq(r[k][a])]; lv=[k for k in mv if eq(r[k][a]) and not eq(r[k][b])]
    rc=[k for k,d in r.items() if d[a].get('rc')!=d[b].get('rc')]
    cl=[k for k in mv if r[k][a].get('cmplines')!=r[k][b].get('cmplines')]
    print(f"{a}->{b}: caseviews={len(r)} moving={len(mv)} entering={len(ent)} leaving={len(lv)} rcchg={len(rc)} cmplinechg={len(cl)}")
    if a=='L' or lv: print('   moving:',sorted(mv)[:40]); print('   leaving:',lv)
    if cl: print('   cmplines:',[(k,r[k][a].get('cmplines'),r[k][b].get('cmplines')) for k in cl][:20])
print('rc!=0:',sorted(set((k,d['P'].get('rc'),d['L'].get('rc'),d['F'].get('rc')) for k,d in r.items() if d['P'].get('rc')!='0' or d['F'].get('rc')!='0')))
