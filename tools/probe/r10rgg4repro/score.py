#!/usr/bin/env python3
"""r10rgg4/score.py — order-blind FIXED/BROKEN scoring over grid cells.

  usage: score.py <cell> ...            (run run_grid.sh first)

Joins gold.rng / ours_BASE.dump.rng-equivalent / ours_PAT... on the measurement
KEY (scope|site + slot) and classifies:
  FIXED  base!=gold, pat==gold      BROKEN base==gold, pat!=gold
  STILL  both wrong                 OK     both right
  MISS   the key is absent on one side (COUNTED as a problem)
"""
import os, re, sys, subprocess, collections

HERE = os.path.dirname(os.path.abspath(__file__))

def attrib(dump):
    if not os.path.exists(dump):
        return None
    r = subprocess.run([sys.executable, os.path.join(HERE, 'attrib.py'), dump],
                       capture_output=True, text=True)
    out = {}
    for ln in r.stdout.splitlines():
        f = ln.split()
        # The KEY's site location is normalised to its START LINE: a DEF-view
        # `array_typespec` span differs by ONE COLUMN between golden and ours
        # (`9:3-9:19` vs `9:3-9:20`) on every cell, base and patch alike, and no
        # Compare reads it -- keying on the full span turned that ONE pre-existing
        # residue into 8 phantom MISS rows per cell.
        site = re.sub(r'@(\d+):\d+-\d+:\d+', r'@\1', f[0])
        out['%s %s' % (site, f[1])] = ' '.join(f[2:]) if len(f) > 2 else ''
    return out

tot = collections.Counter()
for c in sys.argv[1:]:
    d = os.path.join(HERE, c.rstrip('/'))
    G = attrib(os.path.join(d, 'gold.dump'))
    B = attrib(os.path.join(d, 'ours_BASE.dump'))
    P = attrib(os.path.join(d, 'ours_PAT.dump'))
    per = collections.Counter()
    detail = []
    if G is None or not G:
        print('%-26s NO-GOLDEN' % c); tot['MISS'] += 1; continue
    if B is None or P is None:
        print('%-26s NO-DATABASE' % c); tot['MISS'] += 1; continue
    for k in sorted(set(G) | set(B) | set(P)):
        if k not in G or k not in B or k not in P:
            per['MISS'] += 1
            detail.append('MISS   %s  G=%s B=%s P=%s' % (k, G.get(k, '-'), B.get(k, '-'), P.get(k, '-')))
            continue
        gb, gp = G[k] == B[k], G[k] == P[k]
        if gb and gp: per['OK'] += 1
        elif not gb and gp:
            per['FIXED'] += 1
            detail.append('FIXED  %s\n         G=%s\n         B=%s' % (k, G[k], B[k]))
        elif gb and not gp:
            per['BROKEN'] += 1
            detail.append('BROKEN %s\n         G=%s\n         P=%s' % (k, G[k], P[k]))
        else:
            per['STILL'] += 1
            detail.append('STILL  %s\n         G=%s\n         P=%s' % (k, G[k], P[k]))
    tot.update(per)
    print('%-26s FIXED=%-3d BROKEN=%-3d STILL=%-3d OK=%-3d MISS=%d' %
          (c, per['FIXED'], per['BROKEN'], per['STILL'], per['OK'], per['MISS']))
    if os.environ.get('V'):
        for l in detail: print('   ' + l)
print('TOTAL  FIXED=%d BROKEN=%d STILL=%d OK=%d MISS=%d' %
      (tot['FIXED'], tot['BROKEN'], tot['STILL'], tot['OK'], tot['MISS']))
