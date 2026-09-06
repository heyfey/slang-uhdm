#!/usr/bin/env python3
"""r10uvm170repro/score170.py — the grid scorer.  MEASUREMENT ONLY.

    score170.py <workdir> [tag] [--all]

Reads the `casts.{g,a,b}.txt` listings `grid170.sh` wrote (g = golden/Surelog,
a = pristine, b = patched; the def and elab views concatenated) and scores,
PER CAST SITE, the projection the judge reads on a cast target: the target
typespec's (UhdmType, VpiName).

THE KEY IS THE LINE:COL SPAN WITH THE FILE STRIPPED.  Our databases carry an
EMPTY `vpiFile` on these objects (RESUME.md §9) while Surelog's carry the path,
so a key that includes the file joins NOTHING and reports every cell as
one-sided — which is exactly what the first draft of this script did.

TWO PROJECTIONS, because they answer different questions:

  set   the SET of (kind, name) seen at that span, over all views and all
        wildcard-import clones.  This is the column THIS LAW owns: it is blind
        to how many copies of a package body each side emits.
  ms    the exact MULTISET (copy counts included).  A pre-existing copy-count
        difference lands here as `same-differ` on BOTH binaries and is
        therefore visibly NOT this law's doing.

  TOWARD       a != g  and  b == g
  AWAY         a == g  and  b != g
  MOVED-WRONG  a != g  and  b != g  and  a != b
  same-agree   a == g == b
  same-differ  a == b != g
"""
import sys, os, collections


def load(path):
    rows = []
    if not os.path.exists(path):
        return rows
    for ln in open(path):
        f = ln.rstrip("\n").split("\t")
        if not f or f[0] != "CAST":
            continue
        span = f[1]
        # strip the file: "<file>:L:C-L:C" -> "L:C-L:C" (the file may be empty)
        span = span.split(":", 1)[1] if ":" in span else span
        rows.append((span, (f[2], f[3])))
    return rows


def bucket(rows):
    d = collections.defaultdict(collections.Counter)
    for span, v in rows:
        d[span][v] += 1
    return d


def score(G, A, B, proj):
    tot = collections.Counter()
    detail = []
    for span in sorted(set(G) | set(A) | set(B)):
        g, a, b = (proj(G.get(span, collections.Counter())),
                   proj(A.get(span, collections.Counter())),
                   proj(B.get(span, collections.Counter())))
        if a == g and b == g:
            tot["same-agree"] += 1
            continue
        if a == g:
            v = "AWAY"
        elif b == g:
            v = "TOWARD"
        elif a == b:
            v = "same-differ"
        else:
            v = "MOVED-WRONG"
        tot[v] += 1
        detail.append((v, span, g, a, b))
    return tot, detail


def fmt(c):
    return "{" + ", ".join("%s(%s)x%d" % (k[0], k[1], n)
                           for k, n in sorted(c.items())) + "}"


def main():
    W = sys.argv[1]
    tag = sys.argv[2] if len(sys.argv) > 2 else os.path.basename(W.rstrip("/"))
    showall = "--all" in sys.argv
    G = bucket(load(os.path.join(W, "casts.g.txt")))
    A = bucket(load(os.path.join(W, "casts.a.txt")))
    B = bucket(load(os.path.join(W, "casts.b.txt")))
    ncell = len(set(G) | set(A) | set(B))
    print("== %s == cast sites=%d  (golden rows=%d pristine=%d patched=%d)"
          % (tag, ncell, sum(sum(c.values()) for c in G.values()),
             sum(sum(c.values()) for c in A.values()),
             sum(sum(c.values()) for c in B.values())))
    for name, proj in (("set", lambda c: frozenset(c)),
                       ("cnt", lambda c: sum(c.values())),
                       ("ms", lambda c: frozenset(c.items()))):
        tot, detail = score(G, A, B, proj)
        print("  [%s] TOWARD %d  AWAY %d  MOVED-WRONG %d  same-agree %d  "
              "same-differ %d"
              % (name, tot["TOWARD"], tot["AWAY"], tot["MOVED-WRONG"],
                 tot["same-agree"], tot["same-differ"]))
        if name == "cnt":
            for v, span, g, a, b in detail:
                if not showall and v == "same-differ":
                    continue
                print("     %-12s %-16s g=%s a=%s b=%s" % (v, span, g, a, b))
            continue
        for v, span, g, a, b in detail:
            if not showall and name == "ms" and v in ("same-differ",
                                                      "MOVED-WRONG"):
                # the ms projection re-reports every `set` verdict on a span
                # whose COPY COUNT already differs; the `cnt` column above is
                # where that difference is judged.
                continue
            print("     %-12s %-16s g=%s\n%34sa=%s\n%34sb=%s"
                  % (v, span, fmt(collections.Counter(dict(g)) if name == "ms"
                                  else {k: 1 for k in g}), "",
                     fmt(collections.Counter(dict(a)) if name == "ms"
                         else {k: 1 for k in a}), "",
                     fmt(collections.Counter(dict(b)) if name == "ms"
                         else {k: 1 for k in b})))


main()
