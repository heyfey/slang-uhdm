import re,sys
files=[l.strip() for l in open('/tmp/r11u439_scratch/src_ff.lst')]
fre=re.compile(r'foreach\s*\(\s*[\w.:\[\]]*?\[([^\]\)]*)\]\s*\)')
hits=[]
for f in files:
    try: t=open(f,errors='replace').read()
    except Exception: continue
    if 'foreach' not in t: continue
    t2=re.sub(r'//[^\n]*','',t); t2=re.sub(r'/\*.*?\*/','',t2,flags=re.S)
    names=set()
    for m in fre.finditer(t2):
        for n in m.group(1).split(','):
            n=n.strip()
            if re.fullmatch(r'[A-Za-z_]\w*',n): names.add(n)
    if not names: continue
    found=[]
    for n in names:
        # a declaration of n other than inside foreach: type keyword ... n ; or , n
        if re.search(r'\b(int|integer|logic|reg|bit|wire|byte|shortint|longint|genvar|var|tri|uwire|wand|wor|input|output|inout|string|time)\b[^;()]*\b'+re.escape(n)+r'\b\s*(\[[^\]]*\]\s*)*[;,=)]',t2):
            found.append(n)
    if found: hits.append((f,sorted(found)))
for f,n in hits: print(f, ' '.join(n))
