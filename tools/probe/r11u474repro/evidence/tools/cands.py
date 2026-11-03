# cands.py: sv-tests rows whose own sources (files + incdir .sv/.svh, never the bundled UVM library) hold a shape
# one of the r11u474 laws can reach; prints "<row> <slang argv...>" lines
import os,re,shlex,glob,sys
fence=[l.strip() for l in open('/tmp/r11u474_fenced.txt') if l.strip()]
W='/tmp/intr11u472/svtests/work'
pat=re.compile(r'typedef\s+\w+\s*#\s*\(|\[[^\]\n]*\b\w+::\w+[^\]\n]*\]|\.\w+\s*\(\s*\w+::\w+\s*\)|#\s*\(\s*\w+::\w+')
out=[]
for root,ds,fs in os.walk(W):
    if 'cmds.txt' not in fs: continue
    rel=os.path.relpath(root,W)
    if any(f in rel for f in fence): continue
    line=[l for l in open(os.path.join(root,'cmds.txt')) if l.startswith('slang:')]
    if not line: continue
    argv=shlex.split(line[0][len('slang:'):])
    srcs=[a for a in argv[1:] if a.endswith(('.sv','.v','.svh')) and 'third_party/UVM' not in a]
    incs=[a[2:] for a in argv if a.startswith('-I') and 'third_party/UVM' not in a]
    files=set(srcs)
    for d in incs: files|=set(glob.glob(d+'/*.sv'))|set(glob.glob(d+'/*.svh'))
    hit=False
    for f in files:
        try:
            if pat.search(open(f,errors='replace').read()): hit=True;break
        except Exception: pass
    if hit: out.append(rel+'\t'+shlex.join(argv[1:]))
open('/tmp/r11u474_cands.tsv','w').write('\n'.join(out)+'\n')
print(len(out))
