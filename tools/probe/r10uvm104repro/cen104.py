#!/usr/bin/env python3
"""r10uvm104 census - golden-vs-ours over every string-valued object, keyed by
(object kind, owner span, dump depth, field) and joined as a MULTISET.

LHS is ALWAYS golden.  The key deliberately EXCLUDES the text, so a cell whose
text changed stays one matched key carrying two different values instead of
becoming a pair of orphans; the dump DEPTH is part of the key so a cell cannot
hide under a slot.  Colliding keys are counted with a Counter, never a dict
(a last-writer dict drops rows).

  usage: cen104.py <golden.dump> <pristine.dump> <patched.dump>
"""
import re, sys
from collections import Counter

OWNER = re.compile(r'^(\s*)\\_(\w+):(.*?)(?:, id:\d+)?(, line:\d+:\d+, endln:\d+:\d+)?\s*$')
VAL   = re.compile(r'^(\s*)\|(STRING|vpiDecompile):(.*)$')

def cells(path):
    out, stack = [], []
    for ln in open(path, errors='replace'):
        ln = ln.rstrip('\n')
        m = OWNER.match(ln)
        if m:
            ind = len(m.group(1))
            while stack and stack[-1][0] >= ind:
                stack.pop()
            stack.append((ind, m.group(2), (m.group(4) or '').strip()))
            continue
        m = VAL.match(ln)
        if not m:
            continue
        ind = len(m.group(1))
        owner = next(((k, s) for (i, k, s) in reversed(stack) if i < ind), ('?', '?'))
        out.append(((owner[0], owner[1], ind, m.group(2)), m.group(3)))
    return out

def bykey(pairs):
    d = {}
    for k, v in pairs:
        d.setdefault(k, Counter())[v] += 1
    return d

def agree(gm, om):
    same = only_g = only_o = 0
    for k in set(gm) | set(om):
        a, b = gm.get(k, Counter()), om.get(k, Counter())
        same += sum((a & b).values())
        only_g += sum((a - b).values())
        only_o += sum((b - a).values())
    return same, only_g, only_o

gold, pris, pat = (cells(p) for p in sys.argv[1:4])
gm, pm, qm = bykey(gold), bykey(pris), bykey(pat)
s0, g0, o0 = agree(gm, pm)
s1, g1, o1 = agree(gm, qm)
print("CELLS golden=%d pristine=%d patched=%d" % (len(gold), len(pris), len(pat)))
print("PRISTINE agree=%d golden_only=%d ours_only=%d" % (s0, g0, o0))
print("PATCHED  agree=%d golden_only=%d ours_only=%d" % (s1, g1, o1))
print("TO-GOLDEN=%d AWAY=%d STILL=%d" % (s1 - s0, max(0, o1 - o0), g1))
