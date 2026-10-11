# v11u289: summarise a vgridf.sh output (P/L/F per case-view, flags PL PF LF FV!=L FU!=P and per-switch movers).
import sys,collections
r=collections.defaultdict(dict)
for l in open(sys.argv[1]):
    p=l.split(); f={}
    for x in p[3:]:
        if '=' in x: k,v=x.split('=',1); f[k]=v
    if p[2] in ('SURELOG_FAIL','SLANG_FAIL'): f['strict']=p[2]; f['md5']='-'
    r[p[1]][p[0]]=f
def s(f): return f"{f.get('rc')}/{f.get('cmplines')}/{f.get('strict','?').replace('STRICT_','').replace('_objects','')}"
for cv in sorted(r):
    d=r[cv]; P,L,F=d.get('P',{}),d.get('L',{}),d.get('F',{})
    flags=[]
    if P.get('md5')!=L.get('md5'): flags.append('PL')
    if P.get('md5')!=F.get('md5'): flags.append('PF')
    if L.get('md5')!=F.get('md5'): flags.append('LF')
    if d.get('FV',{}).get('md5')!=L.get('md5'): flags.append('FV!=L')
    if d.get('FU',{}).get('md5')!=P.get('md5'): flags.append('FU!=P')
    for k in d:
        if k not in('P','L','F','FV','FU') and d[k].get('md5')!=F.get('md5'): flags.append(k.replace('R11U289_','').replace('R11V289_','V').replace('_OFF',''))
    print(f"{cv:46s} P={s(P):28s} L={s(L):28s} F={s(F):28s} {','.join(flags)}")
