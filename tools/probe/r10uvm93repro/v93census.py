import sys, os, re, subprocess
sys.path.insert(0,'/tmp/v93_arms')
import importlib.util
spec=importlib.util.spec_from_file_location('sl','/tmp/v93_arms/slice.py')
# reuse parse() by exec
src=open('/tmp/v93_arms/slice.py').read().split("for p in sys.argv")[0]
ns={}
exec(src, ns)
parse=ns['parse']
def key(rec):
    # (source line, ordinal within line) — col differs golden-vs-ours by design
    return rec[0].split(':')[0]
def payload(rec):
    if rec[2]=='NO-OPERANDS': return 'NONE'
    return f"{rec[3]}/{rec[4]}/{rec[6]}"
base='/tmp/v93_armwd'
tot={'TO-GOLDEN':0,'AWAY':0,'STILL-RIGHT':0,'STILL-WRONG':0}
rows=[]
for arm in sorted(os.listdir(base)):
    d=os.path.join(base,arm)
    g=os.path.join(d,'g.dump'); p=os.path.join(d,'pris.dump'); q=os.path.join(d,'pat.dump')
    if not (os.path.exists(g) and os.path.exists(p) and os.path.exists(q)): continue
    def bucket(path):
        m={}
        for r in parse(path):
            k=key(r); m.setdefault(k,[]).append(payload(r))
        return m
    G,P,Q=bucket(g),bucket(p),bucket(q)
    for k in sorted(set(G)|set(P)|set(Q), key=lambda x:int(x) if x.isdigit() else 0):
        gl,pl,ql=G.get(k,[]),P.get(k,[]),Q.get(k,[])
        n=max(len(gl),len(pl),len(ql))
        for i in range(n):
            gv=gl[i] if i<len(gl) else '<absent>'
            pv=pl[i] if i<len(pl) else '<absent>'
            qv=ql[i] if i<len(ql) else '<absent>'
            pr=(pv==gv); qr=(qv==gv)
            if pr and qr: c='STILL-RIGHT'
            elif not pr and qr: c='TO-GOLDEN'
            elif pr and not qr: c='AWAY'
            else: c='STILL-WRONG'
            tot[c]+=1
            if c in ('AWAY',) or (c=='STILL-WRONG' and pv!=qv):
                rows.append((c,arm,k,'G='+gv,'P='+pv,'Q='+qv))
print('CENSUS totals:', tot)
print('--- AWAY cells and CHANGED-but-still-wrong cells:')
for r in rows: print('  ', r)
