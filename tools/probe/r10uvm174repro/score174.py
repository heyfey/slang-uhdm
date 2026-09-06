#!/usr/bin/env python3
"""r10uvm174 — score one grid arm.  MEASUREMENT ONLY; the official uhdm-cmp is
the judge.  LHS is ALWAYS golden (Surelog); the two RHS columns are the
pristine (a) and the patched (b) binary.

A POSITION is (listing, home, call name, line, start column) — the source site
a type-query system call was written at.  Membership in a side's KEEP set means
that side left a `sys_func_call` there; absence means it FOLDED (or has no such
position at all, which --list makes visible).

    TO-GOLDEN    pristine disagrees with golden, patched agrees
    AWAY-GOLDEN  pristine agrees with golden, patched does not
    STILL-WRONG  neither binary agrees with golden
    OK           both agree with golden

--nospan drops line/column from the key and scores the MULTISET count per
(listing, home, name) bucket instead: no generated `Compare` reads a span, and
a macro-expanded call's SourceLocation legitimately differs between the two
producers (RESUME §9), so a boundary arm must be judged span-blind.  Per bucket
the score is the distance |ours - golden|: it SHRANK (TO-GOLDEN), it GREW
(AWAY-GOLDEN) or it stayed non-zero (STILL-WRONG).

usage: score174.py <arm workdir> [--view def|elab|both] [--only <substr>]
                   [--nospan] [--list]
"""
import sys, os, collections

W = sys.argv[1]
view = "both"
only = None
listing = "--list" in sys.argv
nospan = "--nospan" in sys.argv
if "--view" in sys.argv:
    view = sys.argv[sys.argv.index("--view") + 1]
if "--only" in sys.argv:
    only = sys.argv[sys.argv.index("--only") + 1]


def load(p):
    s = []
    if not os.path.exists(p):
        return s
    for ln in open(p):
        f = ln.rstrip("\n").split("\t")
        if f[0] != "KEEP":
            continue
        s.append((f[1], f[2], f[3], int(f[4]), int(f[5])))
    return s


def keep(keys):
    if not only:
        return keys
    return [k for k in keys if only in k[0] or only in k[1]]


views = ["def", "elab"] if view == "both" else [view]
tot = collections.Counter()
emptygold = 0
for v in views:
    g = keep(load(f"{W}/cen.g.{v}.txt"))
    a = keep(load(f"{W}/cen.a.{v}.txt"))
    b = keep(load(f"{W}/cen.b.{v}.txt"))
    if not g:
        emptygold += 1
    c = collections.Counter()
    rows = []
    if nospan:
        cg = collections.Counter(k[:3] for k in g)
        ca = collections.Counter(k[:3] for k in a)
        cb = collections.Counter(k[:3] for k in b)
        for k in sorted(set(cg) | set(ca) | set(cb)):
            da, db = abs(ca[k] - cg[k]), abs(cb[k] - cg[k])
            if da == 0 and db == 0:
                verdict, n = "OK", cg[k]
            elif db < da:
                verdict, n = "TO-GOLDEN", da - db
                if db:
                    c["STILL-WRONG"] += db
                    tot["STILL-WRONG"] += db
            elif db > da:
                verdict, n = "AWAY-GOLDEN", db - da
            else:
                verdict, n = "STILL-WRONG", db
            c[verdict] += n
            tot[verdict] += n
            rows.append((verdict, k, cg[k], ca[k], cb[k]))
    else:
        sg, sa, sb = set(g), set(a), set(b)
        for k in sorted(sg | sa | sb):
            ing, ina, inb = k in sg, k in sa, k in sb
            if ina == ing and inb == ing:
                verdict = "OK"
            elif ina != ing and inb == ing:
                verdict = "TO-GOLDEN"
            elif ina == ing and inb != ing:
                verdict = "AWAY-GOLDEN"
            else:
                verdict = "STILL-WRONG"
            c[verdict] += 1
            tot[verdict] += 1
            rows.append((verdict, k, int(ing), int(ina), int(inb)))
    print(f"[{v}] cells={sum(c.values())}  OK={c['OK']}  TO-GOLDEN={c['TO-GOLDEN']}  "
          f"AWAY-GOLDEN={c['AWAY-GOLDEN']}  STILL-WRONG={c['STILL-WRONG']}")
    if listing:
        for verdict, k, ng, na, nb in rows:
            if verdict == "OK":
                continue
            pos = "" if nospan else f" @{k[3]}:{k[4]}"
            print(f"    {verdict:12s} g={ng} a={na} b={nb}  "
                  f"{k[0]} | {k[1]} | {k[2]}{pos}")
print(f"TOTAL OK={tot['OK']} TO-GOLDEN={tot['TO-GOLDEN']} "
      f"AWAY-GOLDEN={tot['AWAY-GOLDEN']} STILL-WRONG={tot['STILL-WRONG']} "
      f"EMPTY-GOLDEN-VIEWS={emptygold}")
