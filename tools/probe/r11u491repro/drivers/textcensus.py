import os,re,sys
fence=[l.strip() for l in open('/tmp/r11u491_fence.txt') if l.strip()]
pat=[('defparam',re.compile(r'\bdefparam\b')),
     ('bitneg',re.compile(r'(localparam|parameter)\b[^;]*?=\s*~\s*\(?\s*[A-Za-z_]\w*\s*\)?\s*[;,)]',re.S)),
     ('unszact',re.compile(r"#\s*\([^;]*?\(\s*'[sS]?[bBoOdDhH][0-9a-fA-F_]+\s*\)",re.S)),
     ('ordunsz',re.compile(r"#\s*\(\s*'[sS]?[bBoOdDhH][0-9a-fA-F_]+",re.S)),
     ('sizedact',re.compile(r"#\s*\([^;]*?\d+\s*'([sS][bBoOdDhH]|[bBoOH])[0-9a-fA-F_]+",re.S))]
roots=sys.argv[1:]
for root in roots:
    paths=[]
    for dp,dn,fn in os.walk(root):
        for f in fn:
            if f.endswith(('.sv','.v','.svh','.vh','.inc','.svi','.pkg')):
                paths.append(os.path.join(dp,f))
    paths=[p for p in paths if not any(x in p for x in fence)]
    for p in sorted(paths):
        try: t=open(p,errors='replace').read()
        except Exception: continue
        hits=[n for n,r in pat if r.search(t)]
        if hits: print(p, ','.join(hits))
