import re,glob,os,collections
hdr=open('include/UhdmExporter.h').read().split('\n')
# find member declarations of associative containers with pointer key
decl={}
ptrkey=re.compile(r'std::(map|multimap|set|unordered_map|unordered_set)\s*<\s*(.*)$')
for i,l in enumerate(hdr,1):
    m=re.search(r'std::(map|multimap|set|unordered_map|unordered_set)<',l)
    if not m: continue
    # grab up to 3 lines to catch the member name
    blob=' '.join(hdr[i-1:i+2])
    # member name: identifier followed by ; or = right after the closing template
    mm=re.search(r'>\s*([A-Za-z_][A-Za-z0-9_]*)\s*[;=]',blob)
    if not mm: continue
    name=mm.group(1)
    kind=m.group(1)
    # key type: text right after '<'
    after=l[m.end():]
    key=after.split(',')[0] if kind in('map','multimap','unordered_map') else after.rstrip('>; ')
    if kind in ('set','unordered_set'):
        key=re.sub(r'>\s*[A-Za-z_].*$','',after)
    isptr=('*' in key)
    if not isptr: continue
    if name in decl: continue
    decl[name]=(i,kind,key.strip(),l.strip())
srcs=sorted(glob.glob('src/*.cpp'))
texts={f:open(f).read().split('\n') for f in srcs}
iterated=collections.defaultdict(list)
for f,lines in texts.items():
    for i,l in enumerate(lines,1):
        for name in decl:
            # range-for over the container, or explicit begin/rbegin iteration
            if re.search(r'\bfor\s*\(.*:\s*'+re.escape(name)+r'\s*\)',l) or \
               re.search(re.escape(name)+r'\.(begin|rbegin|cbegin)\s*\(',l):
                iterated[name].append(f+':'+str(i)+'  '+l.strip()[:110])
print("TOTAL pointer-keyed member containers:",len(decl))
print("ITERATED ones:",len(iterated))
for name in sorted(iterated,key=lambda n:-len(iterated[n])):
    i,kind,key,txt=decl[name]
    print("\n### %s  (include/UhdmExporter.h:%d)  std::%s key=%s   sites=%d"%(name,i,kind,key,len(iterated[name])))
    for s in iterated[name]: print("   ",s)
