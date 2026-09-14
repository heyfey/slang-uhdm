#!/usr/bin/env python3
"""r11u32 — TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG, order-blind, per mover.

Reads three uhdm-dumps (golden, pristine-ours, patched-ours), normalises ids
and the workdir path away, drops the weaklyReferenced TAIL (unreachable to the
judge, never counted), and compares LINE MULTISETS (Counter, not sets — a
set-based join is the multiset trap: it silently merges repeated lines).

  TO-GOLDEN   lines the pristine side was short of / over on, that the patched
              side now matches;
  AWAY-GOLDEN lines the pristine side already matched, that the patched side
              no longer does;
  STILL-WRONG the residue.

Calibrate: golden vs golden vs golden must read 0 / 0 / 0.
usage: toaway.py <golden.uhdm> <pristine.uhdm> <patched.uhdm> <tag>
"""
import collections, re, subprocess, sys

DUMP = '/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump'
import os
NOLOC = os.environ.get('NOLOC') == '1'

def lines(path):
    out = subprocess.run([DUMP, path], capture_output=True, text=True).stdout
    L = out.split('\n')
    cut = len(L)
    for i, l in enumerate(L):
        if l.strip().startswith('\\_weaklyReferenced:'):
            cut = i
            break
    L = L[:cut]
    norm = []
    for l in L:
        l = re.sub(r'id:\d+', 'id:#', l)
        l = re.sub(r'file:\S+', 'file:#', l)
        l = re.sub(r'/tmp/\S+', '#', l)
        # NOLOC: Compare NEVER reads VpiFile/line/col (RESUME §9), so the
        # judged view drops every location.  Without this the scorer counts a
        # span shift as an AWAY-GOLDEN line the judge cannot see.
        if NOLOC:
            l = re.sub(r',? ?(line|endln):\d+:\d+', '', l)
        norm.append(l.rstrip())
    return collections.Counter(norm)

def signed(a, b):
    """multiset difference as a Counter of (line -> +n present only in b)."""
    d = collections.Counter()
    for k in set(a) | set(b):
        n = b[k] - a[k]
        if n:
            d[k] = n
    return d

def main():
    g, p, q, tag = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
    G, P, Q = lines(g), lines(p), lines(q)
    dp = signed(G, P)   # pristine's deviation from golden
    dq = signed(G, Q)   # patched's deviation from golden
    to = away = still = 0
    for k in set(dp) | set(dq):
        a, b = dp.get(k, 0), dq.get(k, 0)
        if a and not b:
            to += abs(a)
        elif b and not a:
            away += abs(b)
        else:
            if abs(b) < abs(a):
                to += abs(a) - abs(b)
            elif abs(b) > abs(a):
                away += abs(b) - abs(a)
            still += min(abs(a), abs(b))
    print(f'{tag:34s} TO-GOLDEN {to:5d}   AWAY-GOLDEN {away:5d}   STILL-WRONG {still:5d}'
          f'   (pristine dev {sum(abs(v) for v in dp.values()):5d} -> patched dev {sum(abs(v) for v in dq.values()):5d})')
    if away:
        print('   AWAY lines:')
        for k in sorted(set(dq)):
            if dq[k] and not dp.get(k, 0):
                print(f'     {dq[k]:+d} {k}')

main()
