#!/usr/bin/env python3
"""v11u32 independent TO-GOLDEN / AWAY-GOLDEN scorer.

For one test: dump golden, pristine and patched with uhdm-dump, strip the
banner line and every location suffix (`, line:..`, `file:..`, `id:..`) so the
comparison is in the judged (location-blind) view, then compare the three line
MULTISETS:

  TO-GOLDEN   lines pristine had in excess of golden that patched no longer has,
              plus lines golden has that pristine lacked and patched now has
  AWAY-GOLDEN lines patched has in excess of golden that pristine did NOT have,
              plus lines golden has that pristine had and patched lost
  STILL       excess/missing lines unchanged between pristine and patched

Calibration: run with golden as all three inputs -> 0 / 0 / 0.
"""
import collections
import re
import subprocess
import sys

DUMP = '/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump'
STRIP = re.compile(r'(, line:\d+:\d+, endln:\d+:\d+|, line:\d+:\d+|, id:\d+|, file:[^,]*|,? *endln:\d+:\d+)')


def lines(path):
    r = subprocess.run([DUMP, path], capture_output=True, text=True, timeout=900)
    if r.returncode != 0:
        raise SystemExit('dump failed: ' + path)
    body = r.stdout.partition('\n')[2]
    out = []
    for l in body.split('\n'):
        l = STRIP.sub('', l).rstrip()
        if l.strip():
            out.append(l.strip())
    return collections.Counter(out)


def main():
    g, p, q, tag = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
    G, P, Q = lines(g), lines(p), lines(q)
    keys = set(G) | set(P) | set(Q)
    to = away = still = 0
    detail = []
    for k in keys:
        dg, dp, dq = G[k], P[k], Q[k]
        ep, eq = dp - dg, dq - dg          # signed error before / after
        if abs(eq) < abs(ep):
            to += abs(ep) - abs(eq)
        elif abs(eq) > abs(ep):
            away += abs(eq) - abs(ep)
            detail.append(('AWAY', abs(eq) - abs(ep), k))
        elif ep != 0:
            still += abs(ep)
    print(f'{tag}: TO-GOLDEN {to}  AWAY-GOLDEN {away}  STILL {still}')
    for t, n, k in sorted(detail, key=lambda x: -x[1])[:25]:
        print(f'   {t} x{n}: {k[:140]}')


main()
