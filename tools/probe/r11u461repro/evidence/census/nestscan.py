import re,sys
hits=[]
kw=re.compile(r'\b(struct|union)\b')
for f in open('allfiles.lst').read().split():
    try: t=open(f,errors='replace').read()
    except: continue
    if 'struct' not in t and 'union' not in t: continue
    t=re.sub(r'//[^\n]*','',t); t=re.sub(r'/\*.*?\*/','',t,flags=re.S)
    found=False
    for m in re.finditer(r'\btypedef\s+(struct|union)\b[^{;]*\{',t):
        i=m.end(); d=1
        while i<len(t) and d>0:
            c=t[i]
            if c=='{': d+=1
            elif c=='}': d-=1
            elif d>=1 and kw.match(t,i) and (i==0 or not t[i-1].isalnum() and t[i-1]!='_'): found=True; break
            i+=1
        if found: break
    if found: hits.append(f)
print('\n'.join(hits))
