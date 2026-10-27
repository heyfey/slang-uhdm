import os, re, sys
fen=[l.strip() for l in open('/tmp/r11u443_fenced.txt') if l.strip()]
roots=sys.argv[1:]
paths=[]
for r in roots:
    for dp,dn,fn in os.walk(r):
        for f in fn:
            if f.endswith(('.sv','.v','.svh','.vh','.svi','.inc','.pkg','.sl')):
                paths.append(os.path.join(dp,f))
paths=[p for p in paths if not any(n in p for n in fen)]
FE=re.compile(r'\bforeach\b'); PR=re.compile(r'^\s*program\b',re.M)
a=open('/tmp/r11u443_scan_fe.txt','w'); b=open('/tmp/r11u443_scan_prog.txt','w')
na=nb=0
for p in paths:
    if p.endswith('.sl'): continue
    try: t=open(p,errors='replace').read()
    except Exception: continue
    t=re.sub(r'//[^\n]*','',t)
    if FE.search(t):
        na+=1; a.write(p+'\n')
        if PR.search(t): nb+=1; b.write(p+'\n')
print(len(paths),na,nb)
