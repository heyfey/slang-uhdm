#!/usr/bin/env python3
"""r10buvm32repro/cen32.py — the SCOPED-CALL census join.  MEASUREMENT ONLY.

Reads sweepcen32.sh's TSV (rows tagged `G|<test>|<mode>` / `O|<test>|<mode>`)
and joins golden against ours as a MULTISET on

    (test, mode, span, name, home)

— never a last-writer dict (RESUME §9: keys collide, a dict drops rows) and
never with the DEF/ELAB view in the key.  The reported column is KIND, plus
LINK and NARG as payload.

    cen32.py <cen.tsv> [--only-disagree] [--test T] [--pred]

`--pred` prints the MOVER PREDICTION: one line per (test, mode) with the number
of cells whose kind disagrees, and the distinct (name, span, home) triples.
"""
import sys, collections

def load(p):
    rows = collections.defaultdict(collections.Counter)
    for ln in open(p, errors='replace'):
        f = ln.rstrip('\n').split('\t')
        if len(f) < 10 or f[1] != 'SCALL':
            continue
        side, test, mode = f[0].split('|')
        span, kind, name = f[2], f[3], f[4]
        link = f[5][5:]; narg = f[6][5:]; home = f[7][5:]
        pos = f[8][4:]; reach = f[9][6:]
        if reach != 'Y':
            continue
        rows[(test, mode, side)][(span, name, home, kind, link, narg, pos)] += 1
    return rows

def main():
    src = sys.argv[1]
    only = '--only-disagree' in sys.argv
    pred = '--pred' in sys.argv
    want = None
    if '--test' in sys.argv:
        want = sys.argv[sys.argv.index('--test') + 1]
    rows = load(src)
    keys = sorted({(t, m) for (t, m, s) in rows})
    tot = collections.Counter()
    for (t, m) in keys:
        if want and t != want:
            continue
        G = rows.get((t, m, 'G'), collections.Counter())
        O = rows.get((t, m, 'O'), collections.Counter())
        # cell key = (span, name, home); compare the KIND multiset per cell
        def bycell(c):
            d = collections.defaultdict(collections.Counter)
            for (span, name, home, kind, link, narg, pos), n in c.items():
                d[(span, name, home)][(kind, link, narg, pos)] += n
            return d
        gc, oc = bycell(G), bycell(O)
        bad = []
        for cell in sorted(set(gc) | set(oc)):
            gk = collections.Counter({k[0]: v for k, v in gc[cell].items()})
            ok = collections.Counter({k[0]: v for k, v in oc[cell].items()})
            if gk == ok:
                tot['AGREE'] += 1
                continue
            tot['DISAGREE'] += 1
            bad.append((cell, dict(gk), dict(ok), dict(gc[cell]), dict(oc[cell])))
        if bad or not only:
            print(f"== {t} / {m}: cells g={len(gc)} o={len(oc)} disagree={len(bad)}")
        if pred:
            for cell, gk, ok, gp, op in bad:
                print(f"   MOVER {cell[1]} @{cell[0]}  home={cell[2]}")
                print(f"      G {gk}")
                print(f"      O {ok}")
        else:
            for cell, gk, ok, gp, op in bad:
                print(f"   {cell}\n      G {gp}\n      O {op}")
    print("TOTALS", dict(tot))

main()
