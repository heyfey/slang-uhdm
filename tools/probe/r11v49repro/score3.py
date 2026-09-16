import subprocess, sys, re
arms = sys.argv[1:]
tot = {'TO':0,'AWAY':0,'STILL':0,'SAME':0}
for a in arms:
    def cells(p):
        out = subprocess.run(['python3','shape.py',p],capture_output=True,text=True).stdout
        d={}
        for l in out.splitlines():
            if l.startswith('##'): continue
            f=l.split()
            if len(f)<3: continue
            key=(f[0],f[1],f[2])
            d[key]=' '.join(f[3:])
        return d
    g=cells(a+'.pris/g.dump'); p=cells(a+'.pris/o.dump'); x=cells(a+'.fix/o.dump')
    t=aw=st=sa=0
    for k in sorted(set(g)|set(p)|set(x)):
        G=g.get(k,'<absent>'); P=p.get(k,'<absent>'); X=x.get(k,'<absent>')
        if P==X:
            if P==G: sa+=1
            else: st+=1; print(f"  STILL {a} {k[0]:16s}{k[1]:26s} G={G}\n{'':24s}ours={P}")
        else:
            if X==G: t+=1; print(f"  TO    {a} {k[0]:16s}{k[1]:26s} -> {X}")
            elif P==G: aw+=1; print(f"  AWAY  {a} {k[0]:16s}{k[1]:26s} G={G}\n{'':24s}law={X}")
            else: print(f"  MOVED-NEITHER {a} {k[0]:16s}{k[1]:26s} G={G}\n{'':24s}pris={P}\n{'':24s}law={X}")
    print(f"ARM {a}  TO {t}  AWAY {aw}  STILL {st}  SAME {sa}")
    tot['TO']+=t; tot['AWAY']+=aw; tot['STILL']+=st; tot['SAME']+=sa
print(f"VERIFIER GRID TOTAL over {len(arms)} arms: TO {tot['TO']}  AWAY {tot['AWAY']}  STILL {tot['STILL']}  SAME {tot['SAME']}")
