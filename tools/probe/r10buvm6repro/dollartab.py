#!/usr/bin/env python3
"""r10buvm6 — the CONSTANT-PARENTING TABLE for one arm workdir.

For every `constant` object in g.dump (golden) and o.dump (ours), prints the
source (line,col) it spans, its vpiDecompile, and the PARENT KIND the dump shows
(`-` = unparented, `<absent>` = the object does not exist on that side).  The
whole point of the arm is the `$` rows: golden's parenting of a `$` bound must
be readable next to the INTEGER twin in the same position.

LHS is ALWAYS golden; RHS is ALWAYS ours.

    usage: dollartab.py <armdir> [<arm-source-basename>]

GUARD: a `constant:` line with no vpiParent line following it is UNPARENTED, not
"parent unknown" — uhdm-dump prints the field whenever it is set, and reading a
missing field as "not printed yet" is what would turn this table into a guess.
"""
import re
import sys
import os
from collections import Counter

D = sys.argv[1]
def cells(f):
    lines = open(os.path.join(D, f)).read().split('\n')
    out = {}
    for i, l in enumerate(lines):
        m = re.match(r'(\s*)\\_constant: , line:(\d+):(\d+), endln:(\d+):(\d+)', l)
        if not m:
            continue
        nxt = lines[i + 1].strip() if i + 1 < len(lines) else ''
        par = '-'
        if nxt == '|vpiParent:':
            pm = re.match(r'\\_(\w+):', lines[i + 2].strip())
            par = pm.group(1) if pm else '?'
        dec = ''
        for j in range(i + 1, min(len(lines), i + 9)):
            dm = re.match(r'\s*\|vpiDecompile:(.*)$', lines[j])
            if dm:
                dec = dm.group(1)
                break
        out.setdefault((int(m.group(2)), int(m.group(3))), []).append((dec, par))
    return out

g, o = cells('g.dump'), cells('o.dump')
src = []
if len(sys.argv) > 2 and os.path.exists(os.path.join(D, sys.argv[2])):
    src = open(os.path.join(D, sys.argv[2])).read().split('\n')
bad = 0
print('%-10s %-8s %-26s %-26s %s' % ('line:col', 'dec', 'GOLD(parents)', 'OURS(parents)', 'src'))
for k in sorted(set(g) | set(o)):
    gv, ov = g.get(k, []), o.get(k, [])
    dec = (gv or ov)[0][0]
    gp = ','.join(p for _, p in gv) or '<absent>'
    op = ','.join(p for _, p in ov) or '<absent>'
    diff = gp != op
    bad += diff
    text = src[k[0] - 1].strip()[:46] if 0 < k[0] <= len(src) else ''
    print('%-10s %-8s %-26s %-26s %s%s' % ('%d:%d' % k, dec, gp, op, text,
                                           '   <<< DIFF' if diff else ''))
print('-- rows=%d  DIFFERING=%d' % (len(set(g) | set(o)), bad))
