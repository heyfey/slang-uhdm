import sys,re
cols=sys.argv[2].split(',') if len(sys.argv)>2 else ["HNAME","RSPAN","RNAME","ROLE","PROD","LOC","PKGV","CLSV","MODV","APKGV","FORK","BKIND","BSK","BVIS"]
seen=set()
rows=[]
for ln in open(sys.argv[1]):
    if not ln.startswith("ROW="): continue
    d=dict(f.split("=",1) for f in ln.rstrip("\n").split("|") if "=" in f)
    t=tuple(d.get(c,"-") for c in cols)
    if t in seen: continue
    seen.add(t); rows.append((d.get("HNAME",""),tuple(int(x) for x in re.findall(r'\d+',d.get("RSPAN","0"))[:2]),t))
rows.sort(key=lambda r:(r[1]))
for _,_,t in rows: print(" | ".join(t))
