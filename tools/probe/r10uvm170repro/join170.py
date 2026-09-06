#!/usr/bin/env python3
"""r10uvm170repro/join170.py — the corpus census join.  MEASUREMENT ONLY.

    join170.py <cenrun-outdir> [--rows] [--only-moved]

Scores, for every row `cenrun170.sh` produced, every WRITTEN CAST TARGET in
the corpus, on the projection the judge reads: the target typespec's
(UhdmType, VpiName).  It reports FOUR columns:

  DEGRADE-TOWARD  golden has an `unsupported_typespec` where pristine had a
                  resolved one and patched now matches golden
  MUST-STAY-AWAY  golden RESOLVES and patched degrades it  (an AWAY move; the
                  reverse column the brief demands, and it must be ZERO)
  MOVED-WRONG     patched moved the cell but not onto golden
  untouched       pristine == patched at that cell (whatever golden says)

The key is the (row, mode, LINE:COL span) with the FILE STRIPPED, because our
databases carry an empty `vpiFile` on these objects while Surelog's carry the
path.  The value is the MULTISET of (kind, name) at that span — a set-valued
join, so a wildcard-import clone cannot force an invented pairing.
"""
import sys, os, collections, glob


def load(path):
    d = collections.defaultdict(collections.Counter)
    if not os.path.exists(path):
        return d
    for ln in open(path):
        f = ln.rstrip("\n").split("\t")
        if not f or f[0] != "CAST":
            continue
        span = f[1]
        span = span.split(":", 1)[1] if ":" in span else span
        d[span][(f[2], f[3])] += 1
    return d


def main():
    OUT = sys.argv[1]
    showrows = "--rows" in sys.argv
    tot = collections.Counter()
    perrow = collections.Counter()
    detail = []
    tags = sorted({os.path.basename(p)[:-len(".g.casts")]
                   for p in glob.glob(os.path.join(OUT, "*.g.casts"))})
    for tag in tags:
        G = load(os.path.join(OUT, tag + ".g.casts"))
        A = load(os.path.join(OUT, tag + ".a.casts"))
        B = load(os.path.join(OUT, tag + ".b.casts"))
        for span in sorted(set(G) | set(A) | set(B)):
            g = frozenset(G.get(span, ()))
            a = frozenset(A.get(span, ()))
            b = frozenset(B.get(span, ()))
            if a == b:
                tot["untouched"] += 1
                continue
            gunsup = any(k[0] == "unsupported_typespec" for k in g)
            if b == g:
                v = "DEGRADE-TOWARD" if gunsup else "TOWARD-OTHER"
            elif a == g:
                v = "MUST-STAY-AWAY"
            else:
                v = "MOVED-WRONG"
            tot[v] += 1
            perrow[(tag, v)] += 1
            detail.append((v, tag, span, sorted(g), sorted(a), sorted(b)))
    print("rows=%d  cells=%d" % (len(tags), sum(tot.values())))
    for k in ("DEGRADE-TOWARD", "TOWARD-OTHER", "MUST-STAY-AWAY",
              "MOVED-WRONG", "untouched"):
        print("  %-16s %d" % (k, tot[k]))
    for v, tag, span, g, a, b in detail:
        print("  %-16s %-34s %-14s g=%s a=%s b=%s" % (v, tag, span, g, a, b))
    if showrows:
        print("-- per row --")
        for (tag, v), n in sorted(perrow.items()):
            print("  %-34s %-16s %d" % (tag, v, n))


main()
