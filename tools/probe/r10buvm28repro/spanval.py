#!/usr/bin/env python3
"""r10buvm28 — extract, from an uhdm-dump, every constant / sys_func_call /
operation keyed by (file-relative line, start col, end col) with its
vpiDecompile.  MEASUREMENT ONLY.  Used to score a golden grid against ours."""
import re, sys, collections
def load(path):
    lines = open(path, errors='replace').read().split('\n')
    out = collections.defaultdict(set)
    for i, l in enumerate(lines):
        m = re.search(r'\\_(constant|sys_func_call|operation|ref_obj):\s*(?:\(([^)]*)\))?\s*, line:(\d+):(\d+), endln:(\d+):(\d+)', l)
        if not m:
            continue
        kind, nm, ln, c1, c2 = m.group(1), m.group(2) or "", int(m.group(3)), int(m.group(4)), int(m.group(6))
        # Attributes of THIS object are the lines indented exactly two more
        # than its own header; a nested `vpiParent:` block re-prints the
        # PARENT at that same +2, so scan by indent and stop at the first
        # line that dedents back to the object's own level or less.
        ind = len(l) - len(l.lstrip())
        dec = ''
        for j in range(i+1, min(i+40, len(lines))):
            lj = lines[j]
            if not lj.strip():
                continue
            ij = len(lj) - len(lj.lstrip())
            if ij <= ind:
                break
            d = re.match(r'\s*\|vpiDecompile:(\S*)', lj)
            if d and ij == ind + 2:
                dec = d.group(1); break
        out[(ln, c1, c2)].add((kind, nm, dec))
    return out
def main():
    g, o = load(sys.argv[1]), load(sys.argv[2])
    lo, hi = (int(sys.argv[3]), int(sys.argv[4])) if len(sys.argv) > 4 else (0, 10**9)
    keys = sorted(k for k in set(g) | set(o) if lo <= k[0] <= hi)
    same = diff = gonly = oonly = 0
    for k in keys:
        gv, ov = g.get(k), o.get(k)
        if gv == ov:
            same += 1
            if '-v' in sys.argv: print('SAME  %-14s %s' % ('%d:%d-%d' % k, sorted(gv)))
            continue
        if gv is None: oonly += 1; tag = 'OURS_ONLY'
        elif ov is None: gonly += 1; tag = 'GOLD_ONLY'
        else: diff += 1; tag = 'DIFF'
        print('%-9s %-14s G=%s  O=%s' % (tag, '%d:%d-%d' % k, sorted(gv) if gv else '-', sorted(ov) if ov else '-'))
    print('== SAME %d DIFF %d GOLD_ONLY %d OURS_ONLY %d' % (same, diff, gonly, oonly))
main()
