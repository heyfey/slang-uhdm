#!/usr/bin/env python3
"""r10buvm28 MOVER PREDICTOR — MEASUREMENT ONLY, run on PRISTINE databases.

§ enumNoBaseTypespecZeroBits28 changes only the VALUE of a folded type query
whose typespec reaches a BASE-LESS enum, and golden's value for such a cell is
ZERO (a struct/array containing one contributes 0 for that leaf).  So every
cell the law can move shows up in the pristine census as a span where

  * golden folded to 0 and we folded to something else            -> TO-GOLDEN
  * golden KEPT the call and we folded                            -> STILL-WRONG
    (only when the argument reaches a base-less enum; listed for inspection)
  * golden folded to N < ours                                     -> candidate
    (a struct/array whose enum leaf golden counts as 0)

It scans EVERY span of the census, including the ones join28.py files as
OUT_OF_SCOPE (a macro-body fold wears SRC- and would hide there).
"""
import sys, os, glob, collections

def load(p):
    d = collections.defaultdict(list)
    if not os.path.exists(p): return d
    for line in open(p):
        line = line.rstrip('\n')
        if not line: continue
        f = line.split('\t')
        if len(f) < 6: continue
        sp = f[0]; i = sp.find(':')
        d[sp[i+1:]].append(tuple(f[1:]) + (sp[:i],))
    return d

def main():
    outdir = sys.argv[1]
    per = collections.Counter()
    rows = []
    for gp in sorted(glob.glob(os.path.join(outdir, '*.g'))):
        key = os.path.basename(gp)[:-2]
        G = load(gp); O = load(gp[:-2] + '.o')
        for sp in sorted(set(G) | set(O)):
            g = sorted((x[0], x[1]) for x in G.get(sp, []))
            o = sorted((x[0], x[1]) for x in O.get(sp, []))
            if g == o: continue
            gv = [x[1] for x in g if x[0] == 'CONST']
            ov = [x[1] for x in o if x[0] == 'CONST']
            gc = [x for x in g if x[0] == 'CALL']
            if gv and ov and set(gv) == {'0'} and set(ov) != {'0'}:
                tag = 'TO-GOLDEN-ZERO'
            elif gv and ov and gv != ov and all(v.isdigit() for v in gv + ov) \
                 and max(int(v) for v in gv) < max(int(v) for v in ov):
                tag = 'GOLD-SMALLER'
            elif gc and ov:
                tag = 'GOLD-KEEPS-WE-FOLD'
            else:
                continue
            per[tag] += 1
            rows.append((tag, key, sp, ';'.join('%s:%s' % x for x in g),
                         ';'.join('%s:%s' % x for x in o)))
    for r in sorted(rows):
        print('%-19s %-34s %-24s G=%-22s O=%s' % r)
    print('--- predictor totals ---')
    for k, v in sorted(per.items()): print('%-19s %d' % (k, v))
    print('databases touched: %d' % len(set(r[1] for r in rows)))

main()
