#!/usr/bin/env bash
# r10buvm18repro/cenall18.sh — THE THREE-WAY PARAMETER-TYPESPEC CENSUS over a
# whole sweep.  MEASUREMENT ONLY.
#
# For every test directory present in BOTH sweep workdirs it runs
# r10buvm18cen on golden / pristine / patched and joins the rows on the KEY
# (view, owner, parameter name, line:col) as a MULTISET (keys collide: two
# packages can list the same parameter name at the same loc through an import,
# and a last-writer dict would silently drop rows).  Object ids and instance
# ids are normalised out of the VALUE -- they are arena addresses, invisible to
# uhdm-cmp, and they differ between every pair of databases.
#
# Verdicts per cell: TO-GOLDEN (pristine wrong, patched right),
# AWAY (pristine right, patched wrong), STILL-WRONG, STILL-RIGHT.
#
# usage: cenall18.sh <golden-workdir-with-cmds> <pristine-workdir> <patched-workdir> [out]
set -u
CEN=${CEN:-/tmp/r10buvm18_cen}
PW=${1:?pristine workdir}; QW=${2:?patched workdir}; OUT=${3:-/tmp/r10buvm18_cenall}
rm -rf "$OUT"; mkdir -p "$OUT"
python3 - "$PW" "$QW" "$OUT" "$CEN" <<'PY'
import os, re, subprocess, sys, collections
PW, QW, OUT, CEN = sys.argv[1:5]
norm = lambda s: re.sub(r'inst=([a-z_]+)#\d+', r'inst=\1',
                 re.sub(r' id=\d+', '', re.sub(r'#\d+', '', s)))
def cen(p):
    if not os.path.isfile(p): return None
    try: out = subprocess.run([CEN, p], capture_output=True, text=True, timeout=900).stdout
    except Exception: return None
    m = collections.Counter()
    for ln in out.splitlines():
        f = ln.split('\t')
        if len(f) < 6: continue
        m[(f[0], f[1], f[2], f[3], norm(f[5]))] += 1
    return m
ghit = re.compile(r'golden cache hit ([^)\s]+)')
tot = collections.Counter(); rows = []
for mode in sorted(os.listdir(PW)):
    pmd, qmd = os.path.join(PW, mode), os.path.join(QW, mode)
    if not os.path.isdir(pmd) or not os.path.isdir(qmd): continue
    for t in sorted(os.listdir(pmd)):
        pu, qu = os.path.join(pmd, t, 'slang.uhdm'), os.path.join(qmd, t, 'slang.uhdm')
        c = os.path.join(pmd, t, 'cmds.txt')
        if not (os.path.isfile(pu) and os.path.isfile(qu) and os.path.isfile(c)): continue
        m = ghit.search(open(c, errors='replace').read())
        if not m: continue
        g = os.path.join(m.group(1), 'golden.uhdm')
        G, P, Q = cen(g), cen(pu), cen(qu)
        if G is None or P is None or Q is None: continue
        keys = set(k[:4] for k in list(G)+list(P)+list(Q))
        for k in keys:
            gv = collections.Counter({kk[4]: v for kk, v in G.items() if kk[:4] == k})
            pv = collections.Counter({kk[4]: v for kk, v in P.items() if kk[:4] == k})
            qv = collections.Counter({kk[4]: v for kk, v in Q.items() if kk[:4] == k})
            pg, qg = (pv == gv), (qv == gv)
            if pv == qv: v = 'STILL-RIGHT' if pg else 'STILL-WRONG'
            elif not pg and qg: v = 'TO-GOLDEN'
            elif pg and not qg: v = 'AWAY'
            else: v = 'CHANGED-STILL-WRONG'
            tot[v] += 1
            if v in ('TO-GOLDEN', 'AWAY', 'CHANGED-STILL-WRONG'):
                rows.append('%s\t%s\t%s\t%s' % (v, t.rsplit('-',1)[0], mode, '\t'.join(k)))
open(os.path.join(OUT, 'moved.txt'), 'w').write('\n'.join(sorted(rows)) + '\n')
for k in ('TO-GOLDEN', 'AWAY', 'CHANGED-STILL-WRONG', 'STILL-WRONG', 'STILL-RIGHT'):
    print('%-20s %d' % (k, tot[k]))
PY
echo "rows -> $OUT/moved.txt"
