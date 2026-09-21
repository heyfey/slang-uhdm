import importlib.util, os, re, sys, glob
import os as _os
here=_os.environ.get('V76GRID','/tmp/v11u76_probe')
spec=importlib.util.spec_from_file_location('shape', here+'/shape.py')
sh=importlib.util.module_from_spec(spec); spec.loader.exec_module(sh)
def rows(p):
    out={}; seen={}
    if not os.path.exists(p): return None
    for sect,name,loc,d in sh.parse(p):
        if sect!='uhdmtopModules' or not d.startswith('op='): continue
        m=re.search(r'ops=\[(.*)\]$',d)
        k=name; n=seen.get(k,0); seen[k]=n+1
        out[(name,n)]=m.group(1).split() if m.group(1) else []
    return out
tot={'FULL':0,'AWAY':0,'STILL':0,'WRONG2':0,'EQUAL':0}
for g in sorted(glob.glob(here+'/grid/*.g.dump')):
    arm=os.path.basename(g)[:-7]
    G=rows(g); P=rows(here+'/grid/%s.pris.dump'%arm); L=rows(here+'/grid/%s.law.dump'%arm)
    if G is None or P is None or L is None: print('SKIP',arm); continue
    c={'FULL':0,'AWAY':0,'STILL':0,'WRONG2':0,'EQUAL':0}
    for k in sorted(set(G)|set(P)|set(L)):
        gg=G.get(k,[]); pp=P.get(k,[]); ll=L.get(k,[])
        for i in range(max(len(gg),len(pp),len(ll))):
            gv=gg[i] if i<len(gg) else '<absent>'
            pv=pp[i] if i<len(pp) else '<absent>'
            lv=ll[i] if i<len(ll) else '<absent>'
            if pv==gv and lv==gv: c['EQUAL']+=1
            elif pv!=gv and lv==gv: c['FULL']+=1
            elif pv==gv and lv!=gv: c['AWAY']+=1; print('  AWAY %s %s op%d g=%s law=%s'%(arm,k[0],i,gv,lv))
            elif pv==lv: c['STILL']+=1
            else: c['WRONG2']+=1; print('  WRONG2 %s %s op%d g=%s pris=%s law=%s'%(arm,k[0],i,gv,pv,lv))
    for x in c: tot[x]+=c[x]
    print('%-16s FULL=%d AWAY=%d STILL=%d WRONG2=%d EQUAL=%d'%(arm,c['FULL'],c['AWAY'],c['STILL'],c['WRONG2'],c['EQUAL']))
print('TOTAL',tot)
