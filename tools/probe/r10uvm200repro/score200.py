#!/usr/bin/env python3
"""r10uvm200repro/score200.py — MULTISET score of a ct200cen census triple.

    score200.py <cen.g> <cen.a:pristine> <cen.b:patched> [--show]

MEASUREMENT ONLY.  The official uhdm-cmp is the judge; this only counts cells.
LHS is ALWAYS golden; RHS is ALWAYS ours.

A cell is  KEY = listing|scope|subroutine|holder|refname|refspan  and
PAYLOAD = the ref_obj's Actual kind + span (`NONE|-` when it carries none) —
exactly what `ref_obj::Compare` reads.  Keys COLLIDE (golden lists one local
twice in a clone), so every join is a MULTISET join: a key maps to a sorted
list of payloads and the lists are compared elementwise (RESUME §9's
"multiset joins; a last-writer dict drops rows").

    AGREE        payload multisets equal on that key
    TO-GOLDEN    disagreed on the pristine binary, agrees on the patched one
    AWAY-GOLDEN  agreed on the pristine binary, disagrees on the patched one
    MOVED-WRONG  disagreed on BOTH and the payload CHANGED (moved, not to golden)
    STILL-WRONG  disagreed on both and did not move
    ONLY-GOLDEN / ONLY-OURS  key present on one side only (per binary)
"""
import sys
from collections import defaultdict


def load(path):
    d = defaultdict(list)
    with open(path) as f:
        for ln in f:
            if not ln.startswith("CEN|"):
                continue
            p = ln.rstrip("\n").split("|")
            # CEN|listing|scope|sub|holder|refname|refspan|actualkind|actualspan
            if len(p) != 9:
                continue
            key = tuple(p[1:7])
            d[key].append("|".join(p[7:9]))
    for k in d:
        d[k].sort()
    return d


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    show = "--show" in sys.argv
    if len(args) != 3:
        print(__doc__)
        return 2
    g, a, b = (load(x) for x in args)
    keys = set(g) | set(a) | set(b)
    agree = to_g = away = wrong = still = partial = 0
    og_a = oo_a = og_b = oo_b = 0
    rows = []
    for k in sorted(keys):
        gv, av, bv = g.get(k), a.get(k), b.get(k)
        if gv is None or av is None:
            if gv is None and av is not None:
                oo_a += 1
            elif gv is not None and av is None:
                og_a += 1
        if gv is None or bv is None:
            if gv is None and bv is not None:
                oo_b += 1
            elif gv is not None and bv is None:
                og_b += 1
        if gv is None or av is None or bv is None:
            if show:
                rows.append(("ONLY", k, gv, av, bv))
            continue
        ok_a, ok_b = gv == av, gv == bv
        if ok_a and ok_b:
            agree += 1
        elif not ok_a and ok_b:
            to_g += 1
            if show:
                rows.append(("TO-GOLDEN", k, gv, av, bv))
        elif ok_a and not ok_b:
            away += 1
            rows.append(("AWAY-GOLDEN", k, gv, av, bv))
        elif av != bv:
            # ARITY RESIDUE, not a wrong move: golden lists one clone body
            # local TWICE (the tf-level Variables copy and the begin's) and we
            # list it once, so a cell whose every payload became golden's can
            # still fail the multiset test on COUNT alone.  Scored apart so
            # MOVED-WRONG stays honest — a sub-multiset of golden that was not
            # one before has moved TOWARD golden and nowhere else.
            def sub(x, y):
                r = list(y)
                for e in x:
                    if e in r:
                        r.remove(e)
                    else:
                        return False
                return True
            if sub(bv, gv) and not sub(av, gv):
                partial += 1
                if show:
                    rows.append(("TO-GOLDEN-ARITY", k, gv, av, bv))
            else:
                wrong += 1
                rows.append(("MOVED-WRONG", k, gv, av, bv))
        else:
            still += 1
            if show:
                rows.append(("STILL-WRONG", k, gv, av, bv))
    for tag, k, gv, av, bv in rows:
        print("%-12s %s\n   golden=%s\n   pris  =%s\n   pat   =%s"
              % (tag, "|".join(k), gv, av, bv))
    print("CELLS golden=%d pris=%d pat=%d" % (len(g), len(a), len(b)))
    print("AGREE %d  TO-GOLDEN %d  TO-GOLDEN-ARITY %d  AWAY-GOLDEN %d  "
          "MOVED-WRONG %d  STILL-WRONG %d"
          % (agree, to_g, partial, away, wrong, still))
    print("ONLY-GOLDEN pris=%d pat=%d   ONLY-OURS pris=%d pat=%d"
          % (og_a, og_b, oo_a, oo_b))
    return 0


if __name__ == "__main__":
    sys.exit(main())
