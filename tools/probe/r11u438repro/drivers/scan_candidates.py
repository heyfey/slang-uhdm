import os,re,sys
fen=[l.strip() for l in open('/tmp/r11u438_s/fenced.txt') if l.strip()]
roots=sys.argv[1:]
paths=[]
for r in roots:
    for dp,dn,fn in os.walk(r):
        for f in fn:
            if f.endswith(('.sv','.v','.svh','.vh','.inc')):
                paths.append(os.path.join(dp,f))
paths=[p for p in paths if not any(x in p for x in fen)]
uns=re.compile(r"(?<![0-9A-Za-z_\$])'[sS]?[hHdDbBoO]|(?<![0-9A-Za-z_\$\)\]])'[01xXzZ](?![0-9A-Za-z_])")
ca=re.compile(r"\bassign\b\s*(#\s*\S+\s*)?([A-Za-z_][\w$]*)\s*=\s*(.*)$", re.S)
nda=re.compile(r"\b(wire|tri|wand|wor|tri0|tri1|supply0|supply1|uwire)\b[^=;]*?\b([A-Za-z_][\w$]*)\s*(\[[^\]]*\]\s*)*=\s*(.*)$", re.S)
hits=0
for p in paths:
    try: t=open(p,errors='replace').read()
    except: continue
    t=re.sub(r'//[^\n]*','',t); t=re.sub(r'/\*.*?\*/','',t,flags=re.S)
    for st in t.split(';'):
        m=ca.search(st)
        if m and uns.search(m.group(3)) and '?' not in m.group(3):
            print('CA',p,m.group(2)); hits+=1; continue
        m=nda.search(st)
        if m and uns.search(m.group(4)):
            print('NDA',p,m.group(2)); hits+=1
print('paths',len(paths),'hits',hits,file=sys.stderr)
