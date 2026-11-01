import sys, os, re, glob
sys.path.insert(0, 'scripts/svtests'); sys.path.insert(0, 'scripts')
import svtests_matrix as m
SV='/home/heyfey/git-repos/sv-tests'
fence=[l.strip() for l in open('/tmp/r11u461_scratch/fence.txt') if l.strip()]
rows=[l.split(',')[0] for l in open('results/golden_svtests.csv').read().splitlines()[1:]]
pat=re.compile(sys.argv[1])
out=[]
for r in rows:
    p=os.path.join(SV,'tests',r)
    if any(f in p for f in fence): continue
    md=m.parse_metadata(p)
    files=[os.path.join(os.path.dirname(p) if not f.startswith('/') else '', f) for f in md['files']]
    hit=False
    for f in [p]+md['files']:
        fp=f if os.path.isabs(f) else os.path.join(SV, f) if os.path.exists(os.path.join(SV,f)) else os.path.join(os.path.dirname(p), f)
        if any(x in fp for x in fence): continue
        try:
            if pat.search(open(fp,errors='replace').read()): hit=True; break
        except Exception: pass
    if hit: out.append(r)
print('\n'.join(out))
