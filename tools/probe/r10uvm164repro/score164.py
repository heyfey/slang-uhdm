#!/usr/bin/env python3
"""r10uvm164 — the cell scorer.  MEASUREMENT ONLY; `uhdm-cmp` is the judge.
G is ALWAYS golden (Surelog), O is ALWAYS ours.

Scores one arm (or one corpus database) three ways and classifies every MOVED
cell by DIRECTION against golden:

  TOWARD   pristine != golden, patched == golden   (a fix)
  AWAY     pristine == golden, patched != golden   (a REGRESSION)
  SIDEWAYS pristine != golden, patched != golden, pristine != patched
  RESHAPE  a cell on one of our columns and absent on the other

Families: CAS (the cast census, keyed CTX x CAST x HOME), REF, TYP, VAR, CNT,
OBJ (the must-not-move families, identical to r10v161repro/scorev161.py's).

usage: score164.py <cen.g.txt> <cen.pris.txt> <cen.pat.txt> [--only FAM] [--nospan]
"""
import sys, collections

argv = sys.argv[1:]
NOSPAN = "--nospan" in argv
only = None
if "--only" in argv:
    only = argv[argv.index("--only") + 1]
paths = [a for a in argv if not a.startswith("--")]
if only:
    paths = [p for p in paths if p != only]
if len(paths) < 3:
    print(__doc__)
    sys.exit(2)


def load(p):
    d = collections.defaultdict(set)
    with open(p) as f:
        for line in f:
            line = line.rstrip("\n")
            if not line:
                continue
            parts = line.split("|")
            fam = parts[0]
            if only and fam != only:
                continue
            tag = parts[1]
            view = tag.split(".")[-1]
            rest = parts[2:]
            if fam == "CAS":
                ctx, cast, home, kind, name, span, val = rest[:7]
                key = (fam, view, ctx, cast, home, kind, name, "" if NOSPAN else span)
                d[key].add(val)
            elif fam == "REF":
                kind, name, span, home, act = rest[0], rest[1], rest[2], rest[3], rest[4]
                key = (fam, view, kind, name, "" if NOSPAN else span, home)
                d[key].add(act)
            elif fam == "TYP":
                name, span, home, act = rest[0], rest[1], rest[2], rest[3]
                key = (fam, view, name, "" if NOSPAN else span, home)
                d[key].add(act)
            elif fam == "VAR":
                scope, vkind, vname, span, auto = rest[0], rest[1], rest[2], rest[3], rest[4]
                key = (fam, view, scope, vkind, vname, "" if NOSPAN else span)
                d[key].add(auto)
            elif fam == "CNT":
                scope, cnt = rest[0], rest[1]
                key = (fam, view, scope)
                d[key].add(cnt)
            elif fam == "OBJ":
                kind, name, span, home = rest[0], rest[1], rest[2], rest[3]
                key = (fam, view, kind, name, "" if NOSPAN else span, home)
                d[key].add("present")
    return d


G, P, Q = load(paths[0]), load(paths[1]), load(paths[2])


def cmp2(a, b):
    diff, only_a, only_b = [], [], []
    for k in sorted(set(a) | set(b)):
        if k not in a:
            only_b.append(k)
        elif k not in b:
            only_a.append(k)
        elif a[k] != b[k]:
            diff.append(k)
    return diff, only_a, only_b


for lab, O in (("PRISTINE", P), ("PATCHED", Q)):
    d, og, oo = cmp2(G, O)
    print(f"{lab:9s} vs GOLDEN:  DIFF {len(d):4d}  ONLY-G {len(og):4d}  ONLY-O {len(oo):4d}")

print("---- MOVED CELLS (pristine column != patched column) ----")
counts = collections.Counter()
for k in sorted(set(P) | set(Q)):
    pv, qv = P.get(k), Q.get(k)
    if pv == qv:
        continue
    gv = G.get(k)
    if pv is None or qv is None:
        verdict = "RESHAPE"
    elif gv is None:
        verdict = "NO-GOLDEN"
    elif pv != gv and qv == gv:
        verdict = "TOWARD"
    elif pv == gv and qv != gv:
        verdict = "AWAY"
    else:
        verdict = "SIDEWAYS"
    counts[verdict] += 1
    print(f"  {verdict:9s} {'|'.join(str(x) for x in k)}")
    print(f"      G={sorted(gv) if gv else None}  pris={sorted(pv) if pv else None}  pat={sorted(qv) if qv else None}")
print("MOVED " + "  ".join(f"{k}={v}" for k, v in sorted(counts.items())) + f"   TOTAL={sum(counts.values())}")
