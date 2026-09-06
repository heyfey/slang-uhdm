#!/usr/bin/env python3
"""r10v177repro/vscore177.py — score one arm's workdir, per view.

LHS is ALWAYS golden.  For every key present on either side:

    AGREE-A / AGREE-B   the pristine / patched value equals golden's
    FIXED               pristine disagreed, patched agrees
    MOVED-WRONG         pristine AGREED, patched does not      <-- the verdict
    STILL-WRONG         both disagree (unchanged)
    MOVED-STILL-WRONG   both disagree but the patched value changed

Rows that are `- - -` on ALL THREE sides are dropped: they are dump elisions
(an already-printed object re-listed under a top-listing section), not cells.
"""
import sys
import os


def load(p):
    d = {}
    if not os.path.exists(p):
        return d
    for ln in open(p):
        f = ln.rstrip("\n").split("\t")
        if len(f) < 4:
            continue
        d[(f[0], f[1], f[2])] = f[3]
    return d


def score(w, view, show):
    g = load(os.path.join(w, "cen.g.%s.txt" % view))
    a = load(os.path.join(w, "cen.a.%s.txt" % view))
    b = load(os.path.join(w, "cen.b.%s.txt" % view))
    keys = sorted(set(g) | set(a) | set(b))
    cnt = {k: 0 for k in ("AGREE-A", "AGREE-B", "FIXED", "MOVED-WRONG",
                          "STILL-WRONG", "MOVED-STILL-WRONG", "CELLS")}
    detail = []
    for k in keys:
        gv, av, bv = g.get(k, "<absent>"), a.get(k, "<absent>"), b.get(k, "<absent>")
        if gv == av == bv == "- - -":
            continue
        cnt["CELLS"] += 1
        ga, gb = (gv == av), (gv == bv)
        cnt["AGREE-A"] += ga
        cnt["AGREE-B"] += gb
        tag = None
        if not ga and gb:
            tag = "FIXED"
        elif ga and not gb:
            tag = "MOVED-WRONG"
        elif not ga and not gb:
            tag = "MOVED-STILL-WRONG" if av != bv else "STILL-WRONG"
        if tag:
            cnt[tag] += 1
            detail.append("   %-18s %s | G=%s | PRIS=%s | PAT=%s"
                          % (tag, " ".join(k), gv, av, bv))
    print("[%s] view=%s CELLS=%d AGREE-PRIS=%d AGREE-PAT=%d FIXED=%d "
          "MOVED-WRONG=%d STILL-WRONG=%d MOVED-STILL-WRONG=%d"
          % (os.path.basename(w.rstrip("/")), view, cnt["CELLS"],
             cnt["AGREE-A"], cnt["AGREE-B"], cnt["FIXED"], cnt["MOVED-WRONG"],
             cnt["STILL-WRONG"], cnt["MOVED-STILL-WRONG"]))
    if show:
        for d in detail:
            print(d)
    return cnt["MOVED-WRONG"]


if __name__ == "__main__":
    w = sys.argv[1]
    show = "--list" in sys.argv[2:]
    bad = 0
    for v in ("def", "elab"):
        bad += score(w, v, show)
    print("TOTAL-MOVED-WRONG=%d" % bad)
