import re, sys, os, collections
pat = re.compile(r'\{\s*(<<|>>)\s*([^{\s][^\s{]*)?\s*\{')
roots = sys.argv[1:]
hits = collections.Counter()
files = collections.defaultdict(collections.Counter)
for root in roots:
    for dp, dn, fn in os.walk(root):
        for f in fn:
            if not f.endswith(('.sv','.svh','.v','.vh')): continue
            p = os.path.join(dp,f)
            try: t = open(p, errors='replace').read()
            except Exception: continue
            for m in pat.finditer(t):
                tok = m.group(2) or '<none>'
                hits[tok]+=1
                files[tok][p]+=1
for tok,c in sorted(hits.items(), key=lambda x:-x[1]):
    print(f'{c:6d}  {tok!r}')
print('---- files per NON-NUMERIC, NON-none token ----')
for tok,c in sorted(hits.items(), key=lambda x:-x[1]):
    if tok=='<none>' or re.match(r'^\d+$',tok) or re.match(r"^\d*'[bdho]",tok): continue
    for p,n in files[tok].items():
        print(f'{n:4d} {tok!r} {p}')
