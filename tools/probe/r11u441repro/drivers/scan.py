import os, re, sys
fen=[l.strip() for l in open('/tmp/r11u441_fenced.txt') if l.strip()]
roots=sys.argv[1:]
paths=[]
for r in roots:
    for dp,dn,fn in os.walk(r):
        for f in fn:
            if f.endswith(('.sv','.v','.svh','.vh','.svi','.inc','.pkg')):
                paths.append(os.path.join(dp,f))
paths=[p for p in paths if not any(n in p for n in fen)]
A=re.compile(r',(?:[ \t]|/\*.*?\*/)*(?://[^\n]*)?\r?\n(?:\s|/\*.*?\*/|//[^\n]*\n)*[,)]', re.S)
B=re.compile(r'\binterface\b')
C=re.compile(r'\+\+|--(?!-)')
na=nb=0
outa=open('/tmp/r11u441_scanA.txt','w'); outb=open('/tmp/r11u441_scanB.txt','w')
for p in paths:
    try: t=open(p,errors='replace').read()
    except Exception: continue
    # strip line comments for B/C
    if A.search(t):
        na+=1; outa.write(p+'\n')
    tt=re.sub(r'//[^\n]*','',t)
    if B.search(tt) and C.search(tt):
        nb+=1; outb.write(p+'\n')
print(len(paths), na, nb)
