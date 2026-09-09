#!/usr/bin/env python3
"""r10v224 — THE FIELD netcen224.py DOES NOT READ.

An interface definition's `array_net` carries a LOC-LESS inner element net.
`netcen224.py` records that net's TYPESPEC and nothing else, so a change to its
`vpiNetType` scores as SAME.  `nets::Compare` READS `VpiNetType`
(UHDM build/generated/src/nets.cpp:277), so the field is judge-visible and a
grid blind to it can report AWAY 0 while a cell moves away.

  usage: innernt224.py <golden.dump> <a.dump> <b.dump> [label]

The dump prints the same object more than once (inline, then as a
back-reference), and the back-reference is TRUNCATED — so each fullname is
scored by its RICHEST occurrence, never its first.
"""
import sys, re

def scan(path):
    lines = open(path, errors='replace').read().split('\n')
    best = {}
    for i, l in enumerate(lines):
        m = re.match(r'^(\s*)\\_logic_net: \(([^)]*)\)\s*$', l)
        if not m:
            continue
        ind = len(m.group(1)); full = m.group(2); parts = full.split('.')
        if len(parts) < 3 or parts[-1] != parts[-2]:
            continue                      # not an array_net inner element net
        nt, ts, j = 'none', 'none', i + 1
        while j < len(lines):
            s = lines[j]
            if not s.strip():
                j += 1; continue
            si = len(s) - len(s.lstrip())
            if si <= ind:
                break
            if si == ind + 2:
                if s.strip().startswith('|vpiNetType:'):
                    nt = s.strip().split(':', 1)[1]
                if s.strip() == '|vpiTypespec:':
                    ts = 'YES'
            j += 1
        score = (nt != 'none') + (ts != 'none')
        if full not in best or score > best[full][2]:
            best[full] = (nt, ts, score)
    return {k: (v[0], v[1]) for k, v in best.items()}

g, a, b = scan(sys.argv[1]), scan(sys.argv[2]), scan(sys.argv[3])
label = sys.argv[4] if len(sys.argv) > 4 else ''
# Scored PER FIELD, not per cell: `nets::Compare` fails on the FIRST field
# that differs, and a cell can be wrong on the typespec before and wrong on
# the netType after while the CELL count never moves.  A per-cell scorer calls
# that "still-wrong" both times and reports AWAY 0.
FIELDS = ('vpiNetType', 'vpiTypespec')
away = fixed = still = same = 0
for k in sorted(set(g) | set(a) | set(b)):
    gv = g.get(k, ('ABSENT', 'ABSENT'))
    av = a.get(k, ('ABSENT', 'ABSENT'))
    bv = b.get(k, ('ABSENT', 'ABSENT'))
    for i, f in enumerate(FIELDS):
        if gv[i] == bv[i]:
            tag = '(fixed)' if gv[i] != av[i] else ''
            fixed += gv[i] != av[i]; same += gv[i] == av[i]
        elif gv[i] == av[i]:
            tag = 'AWAY'; away += 1
        else:
            tag = 'still-wrong'; still += 1
        if tag:
            print('%s  %-46s %-11s G=%-7s A=%-7s B=%-7s %s' %
                  (label, k, f, gv[i], av[i], bv[i], tag))
print('%s SUMMARY fields same=%d fixed=%d still-wrong=%d AWAY=%d' %
      (label, same, fixed, still, away))
