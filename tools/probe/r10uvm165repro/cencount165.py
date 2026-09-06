#!/usr/bin/env python3
# r10uvm165repro/cencount165.py — THE CORPUS CENSUS CROSS-TAB.  MEASUREMENT
# ONLY; the official `uhdm-cmp` is the judge.  LHS is ALWAYS golden (Surelog),
# RHS is ALWAYS ours.
#
#   cencount165.py <census dir written by census165.sh> [--fam ARG]
#
# Joins golden and ours as MULTISETS (never a dict: an elab database holds a
# package class body twice at the same span, and a last-writer dict drops one)
# and cross-tabs the ARG family — every CALL ARGUMENT keyed by
#     POS   the call's position: `stmt` (a statement) or `expr` (a value)
#     RECV  its receiver: `prefix` (a method call through a handle), `bare`
#           (no receiver), `hierpath` (the expression-position dotted shape),
#           `syscall`, `none`
#     D     the CONTROL-BODY DEPTH between the argument and the enclosing
#           subroutine (a begin / named begin / fork raises none)
#     HOME  the enclosing subroutine kind @ its container kind
# against BOUND / BARE, and reports BOTH one-sided sets by name.
import sys, os, glob, collections

FAM = 'ARG'
args = sys.argv[1:]
if '--fam' in args:
    i = args.index('--fam')
    FAM = args[i + 1]
    del args[i:i + 2]
D = args[0]


def load(p):
    c = collections.Counter()
    for l in open(p):
        if not l.startswith(FAM + '|'):
            continue
        f = l.rstrip('\n').split('|')
        # FAM|tag|POS|RECV|D|HOME|kind|name|span|value
        c[(tuple(f[2:6]), tuple(f[6:9]), f[9])] += 1
    return c


rows = sorted(set(os.path.basename(p)[:-6]
                  for p in glob.glob(os.path.join(D, '*.g.txt'))))
tab = collections.Counter()
onlyG, onlyO = collections.Counter(), collections.Counter()
diffs = []
for r in rows:
    g = load(os.path.join(D, r + '.g.txt'))
    o = load(os.path.join(D, r + '.o.txt'))
    for (k, ident, v), n in g.items():
        tab[(k, 'G', v)] += n
    for (k, ident, v), n in o.items():
        tab[(k, 'O', v)] += n
    dg, do = g - o, o - g
    for x, n in dg.items():
        onlyG[x[0]] += n
    for x, n in do.items():
        onlyO[x[0]] += n
    # cell-level disagreement, joined on identity (kind, name, span)
    gi = {(k, i): v for (k, i, v) in g}
    oi = {(k, i): v for (k, i, v) in o}
    for key in sorted(set(gi) & set(oi)):
        if gi[key] != oi[key]:
            diffs.append((r, key, gi[key], oi[key]))

print(f"rows censused: {len(rows)}")
keys = sorted(set(k for (k, s, v) in tab))
print(f"{'POS':<9}{'RECV':<10}{'D':<4}{'HOME':<26}"
      f"{'G-BOUND':>8}{'G-BARE':>8}{'O-BOUND':>9}{'O-BARE':>8}")
for k in keys:
    print(f"{k[0][4:]:<9}{k[1][5:]:<10}{k[2][2:]:<4}{k[3][5:]:<26}"
          f"{tab[(k,'G','BOUND')]:>8}{tab[(k,'G','BARE')]:>8}"
          f"{tab[(k,'O','BOUND')]:>9}{tab[(k,'O','BARE')]:>8}")
print()
print(f"golden-vs-ours DISAGREEING CELLS (joined on kind|name|span): {len(diffs)}")
for r, key, gv, ov in diffs:
    print(f"  {r}  {'|'.join(key[0])}  {'|'.join(key[1])}  golden={gv} ours={ov}")
print()
print(f"ONLY-GOLDEN keys: {sum(onlyG.values())}   ONLY-OURS keys: {sum(onlyO.values())}")
for lbl, c in (('ONLY-G', onlyG), ('ONLY-O', onlyO)):
    for k, n in sorted(c.items()):
        print(f"  {lbl} {'|'.join(k)}  x{n}")
