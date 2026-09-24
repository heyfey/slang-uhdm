#!/usr/bin/env python3
# fieldworse.py <golden> <a> <b> : per-record per-field: fields matching golden in a but not in b (aligned records only up to first length mismatch)
import subprocess, sys, tempfile, os
SC='/tmp/v11u131_bin/strictcmp'
def recs(g,o):
    d=tempfile.mkdtemp(prefix='v11u131_fw'); subprocess.run([SC,'--dump-a',d+'/a','--dump-b',d+'/b',g,o],capture_output=True)
    if not os.path.exists(d+'/b'): return None,None
    r=(open(d+'/a').read().splitlines(), open(d+'/b').read().splitlines()); subprocess.run(['rm','-rf',d]); return r
g,a,b=sys.argv[1:4]
G,A=recs(g,a); G2,B=recs(g,b)
if G is None or G2 is None: print('STAGE1'); sys.exit()
bad=[]
# only compare records while depth/type align in all three
for i in range(min(len(G),len(A),len(B))):
    gf,af,bf=G[i].split('\t'),A[i].split('\t'),B[i].split('\t')
    if gf[:2]!=af[:2] or gf[:2]!=bf[:2]: break
    for k in range(min(len(gf),len(af),len(bf))):
        if gf[k]==af[k] and gf[k]!=bf[k]: bad.append((i,k,gf[k],bf[k]))
print('FIELDWORSE' if bad else 'FIELDOK', len(bad), bad[:3])
