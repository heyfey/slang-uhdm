#!/usr/bin/env python3
"""r10uvm209 — cen209.py — MEASUREMENT ONLY.  The official uhdm-cmp is the sole
judge; this script only reports.  LHS is ALWAYS golden (Surelog), RHS is ALWAYS
ours.

Joins two `ct209cen` outputs (golden, ours) and scores the variable census.

Two faces, scored separately because they answer different questions:

  LISTING  the position-keyed cells of the vectors the judge WALKS
           (`P:` package, `M:all` module DEF view, `M:top` module ELAB view,
           `C:` class).  A cell is RIGHT when golden and ours carry the same
           `<kind>|<name>|A<automatic>|V<visibility>|C<const>` at that
           position, WRONG when both sides have a cell there and they differ,
           ONLY-GOLDEN / ONLY-OURS when one side is short.

  MULTISET every variable object anywhere in the database, as a COUNTED
           multiset of `<kind>|<name>|A|V|C|<span>` — never a dict, because an
           import copy legitimately repeats a face.  MISSING = golden's count
           exceeds ours; EXTRA = ours exceeds golden's.

With `--pris <pris_ours>` it additionally scores the MOVE from a pristine
database to a patched one, cell by cell, and prints MOVED-WRONG (a cell that
was RIGHT and is now WRONG) and AWAY (a multiset face that golden has and that
we had and no longer have, or one golden lacks and we newly minted).  Those two
counters are the acceptance floor this pass is written against.
"""
import sys, collections, argparse


def load(path):
    listing, multi = {}, collections.Counter()
    scope = {}
    with open(path) as fh:
        for line in fh:
            parts = line.rstrip('\n').split('\t')
            if len(parts) < 3:
                continue
            if parts[0] == 'VAR':
                multi[parts[1]] += 1
            else:
                listing[parts[0]] = parts[1]
                scope[parts[0]] = parts[2]
    return listing, multi, scope


def score_listing(g, o):
    right = wrong = og = oo = 0
    wrongs = []
    for k, gv in g.items():
        ov = o.get(k)
        if ov is None:
            og += 1
        elif ov == gv:
            right += 1
        else:
            wrong += 1
            wrongs.append((k, gv, ov))
    for k in o:
        if k not in g:
            oo += 1
    return right, wrong, og, oo, wrongs


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('golden')
    ap.add_argument('ours')
    ap.add_argument('--pris', default=None)
    ap.add_argument('--tag', default='')
    ap.add_argument('--show', type=int, default=12)
    a = ap.parse_args()

    gl, gm, gs = load(a.golden)
    ol, om, _ = load(a.ours)
    right, wrong, og, oo, wrongs = score_listing(gl, ol)
    miss = sum(v for k, v in (gm - om).items())
    extra = sum(v for k, v in (om - gm).items())
    print(f"-- {a.tag} LISTING  RIGHT {right}  WRONG {wrong}  "
          f"ONLY-GOLDEN {og}  ONLY-OURS {oo}")
    print(f"-- {a.tag} MULTISET GOLDEN {sum(gm.values())}  OURS {sum(om.values())}  "
          f"MISSING {miss}  EXTRA {extra}")
    for k, gv, ov in wrongs[:a.show]:
        print(f"   WRONG {k}\n         G={gv}\n         O={ov}   scope={gs.get(k)}")
    if len(wrongs) > a.show:
        print(f"   ... {len(wrongs) - a.show} more WRONG cells")

    if a.pris:
        pl, pm, _ = load(a.pris)
        moved_wrong = to_right = still = 0
        for k, gv in gl.items():
            pv, ov = pl.get(k), ol.get(k)
            if pv == gv and ov != gv:
                moved_wrong += 1
                print(f"   MOVED-WRONG {k} G={gv} PRIS={pv} PATCHED={ov}")
            elif pv != gv and ov == gv:
                to_right += 1
            elif pv != gv and ov != gv:
                still += 1
        # AWAY: a face we HAD that golden also has and that we have LOST, or a
        # face golden does NOT have that we have NEWLY minted.
        away = 0
        for k, c in (pm - om).items():           # lost
            if gm[k] > 0:
                away += min(c, gm[k])
                print(f"   AWAY-LOST {k} pris={pm[k]} patched={om[k]} golden={gm[k]}")
        for k, c in (om - pm).items():           # newly minted
            if gm[k] == 0:
                away += c
                print(f"   AWAY-NEW  {k} pris={pm[k]} patched={om[k]} golden=0")
        print(f"-- {a.tag} MOVE  WRONG->RIGHT {to_right}  STILL-WRONG {still}  "
              f"MOVED-WRONG {moved_wrong}  AWAY {away}")


main()
