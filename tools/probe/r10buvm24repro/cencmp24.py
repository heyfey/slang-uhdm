#!/usr/bin/env python3
"""r10buvm24repro/cencmp24.py — MULTISET join of two r10buvm24cen listings.

MEASUREMENT ONLY.  LHS file is ALWAYS golden, RHS ALWAYS ours.

KEY   = (call loc, call kind, call name, narg)   — view-FREE and owner-FREE
        (buvm23's verifier lesson: a first-root view label classifies the same
        object differently on the two sides; and owner FULLNAMES are naming-
        context dependent).  The join is a MULTISET join: identical keys are
        paired off by sorted payload, never collapsed into a last-writer dict.
PAYLOAD = ARGSIG, the judge-visible argument signature.

  cencmp24.py <cen.golden> <cen.ours> [--only SUBSTR] [--x]
      --only  restrict to rows whose ARGSIG or key contains SUBSTR
      --x     also print the NON-judge-visible ARGX column for DIFF rows
"""
import sys, collections

def load(p):
    d = collections.defaultdict(list)
    for ln in open(p, encoding='utf-8', errors='replace'):
        f = ln.rstrip('\n').split('\t')
        if len(f) < 8 or f[1] != 'CALL':
            continue
        key = (f[2], f[3], f[4], f[5])
        d[key].append((f[6], f[7] if len(f) > 7 else '-'))
    return d

def main():
    a = sys.argv[1:]
    only = None
    showx = False
    args = []
    i = 0
    while i < len(a):
        if a[i] == '--only':
            only = a[i+1]; i += 2
        elif a[i] == '--x':
            showx = True; i += 1
        else:
            args.append(a[i]); i += 1
    G, O = load(args[0]), load(args[1])
    same = diff = gonly = oonly = 0
    for k in sorted(set(G) | set(O)):
        gl = sorted(G.get(k, []))
        ol = sorted(O.get(k, []))
        if only and only not in '\t'.join(x[0] for x in gl + ol) and only not in '\t'.join(k):
            continue
        n = min(len(gl), len(ol))
        for i in range(n):
            if gl[i][0] == ol[i][0]:
                same += 1
            else:
                diff += 1
                print('DIFF\t' + '\t'.join(k))
                print('  G ' + gl[i][0])
                print('  O ' + ol[i][0])
                if showx:
                    print('  gX ' + gl[i][1])
                    print('  oX ' + ol[i][1])
        for i in range(n, len(gl)):
            gonly += 1
            print('GOLDEN-ONLY\t' + '\t'.join(k) + '\t' + gl[i][0])
        for i in range(n, len(ol)):
            oonly += 1
            print('OURS-ONLY\t' + '\t'.join(k) + '\t' + ol[i][0])
    print('SAME %d  DIFF %d  GOLDEN-ONLY %d  OURS-ONLY %d' % (same, diff, gonly, oonly))

main()
