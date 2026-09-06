#!/usr/bin/env python3
"""r10uvm170repro/predict170.py — THE A-PRIORI MOVER PREDICTION.
MEASUREMENT ONLY, and it NEVER READS THE PATCHED BINARY OR ITS DATABASES.

    predict170.py <pristine-workdir> <ct170cen> [name-filter-regex]

For every row of a PRISTINE `verify_golden.py` workdir it reads the row's own
`cmds.txt` for the golden cache path (never guessed), runs `ct170cen --casts`
on the GOLDEN and on the PRISTINE database, and names every cast site where

    golden  has an `unsupported_typespec` whose VpiName has NO `::`
    ours    has anything else

i.e. exactly the population § dpiExportedPkgSubBareOwnTdUnsupported170 claims.
The rows it prints are the rows the patched sweep must move — and no others.

It asserts a nonzero comparable-row count, because a predictor that reaches
nothing must never read as "no movers" (r10uvm168's `predict168.sh` lesson).
"""
import sys, os, re, subprocess, collections


def cen(binpath, db, mode):
    try:
        out = subprocess.run([binpath, db, "--" + mode], capture_output=True,
                             text=True, timeout=1200)
    except subprocess.TimeoutExpired:
        return None
    if out.returncode != 0:
        return None
    return out.stdout


def parse(txt):
    d = collections.defaultdict(set)
    if not txt:
        return d
    for ln in txt.splitlines():
        f = ln.split("\t")
        if not f or f[0] != "CAST":
            continue
        span = f[1]
        span = span.split(":", 1)[1] if ":" in span else span
        d[span].add((f[2], f[3]))
    return d


def main():
    WD, CEN = sys.argv[1], sys.argv[2]
    filt = re.compile(sys.argv[3]) if len(sys.argv) > 3 else None
    comparable = 0
    movers = collections.Counter()
    for mode in ("default", "testflags"):
        base = os.path.join(WD, mode)
        if not os.path.isdir(base):
            continue
        for row in sorted(os.listdir(base)):
            if filt and not filt.search(row):
                continue
            d = os.path.join(base, row)
            ours = os.path.join(d, "slang.uhdm")
            cmds = os.path.join(d, "cmds.txt")
            if not (os.path.exists(ours) and os.path.exists(cmds)):
                continue
            g = None
            for ln in open(cmds):
                m = re.search(r"golden cache hit (/[^)]*)", ln)
                if m:
                    g = os.path.join(m.group(1), "golden.uhdm")
                    break
            if not g or not os.path.exists(g):
                continue
            comparable += 1
            G = parse(cen(CEN, g, "casts"))
            A = parse(cen(CEN, ours, "casts"))
            for span, gv in G.items():
                bare = [k for k in gv
                        if k[0] == "unsupported_typespec" and "::" not in k[1]]
                if not bare:
                    continue
                av = A.get(span, set())
                # THE LAW'S OWN GATE, expressed on the pristine object: it only
                # ever replaces a RESOLVED enum / struct / union typespec (a
                # typedef written as an inline aggregate).  A pristine
                # `int_typespec` at such a span is a SIZE CAST BY A PARAMETER
                # NAME — Earlgrey's `AttrDw` / `NWD` — a different family this
                # law must leave alone, and the byte gate proves it does.
                if not all(k[0] in ("enum_typespec", "struct_typespec",
                                    "union_typespec")
                           for k in av):
                    print("EXCLUDED %-10s %-28s %-14s golden=%s ours=%s"
                          % (mode, row, span, sorted(gv), sorted(av)))
                    continue
                if av != gv:
                    movers[(mode, row)] += 1
                    print("PREDICT %-10s %-28s %-14s golden=%s ours=%s"
                          % (mode, row, span, sorted(gv), sorted(av)))
    assert comparable > 0, "predictor reached NO comparable row"
    print("comparable rows=%d  predicted moving rows=%d  cells=%d"
          % (comparable, len(movers), sum(movers.values())))
    for k in sorted(movers):
        print("  MOVER %s/%s  cells=%d" % (k[0], k[1], movers[k]))


main()
