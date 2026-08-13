#!/usr/bin/env python3
"""r10uvm69repro/calljoin.py — join two callcen.cpp censuses BY THE ARGUMENT-SPAN
KEY and print every cell where the two sides disagree about the CALL SHAPE.

  usage: calljoin.py <g.cen> <o.cen> [--all]

LHS is ALWAYS golden, RHS is ALWAYS ours — the column order here says so and the
banner prints it.

A cell is (key -> kind,name,span,prefix,tgt,owner).  Keys can repeat (two calls
on one line with identical argument columns), so each side is a MULTISET per key
and the join reports counts, never a silent first-wins pick.

Verdicts:
  SHAPE   both sides have a call at this key and the KINDS differ  <- the head
  NAME    same kind, different name
  GONLY   golden has a call here and ours has none
  OONLY   ours has a call here and golden has none
  agree   same kind and same name
"""
import sys
from collections import defaultdict


def load(p):
    d = defaultdict(list)
    with open(p) as f:
        for ln in f:
            if not ln.startswith("KEY "):
                continue
            parts = ln.rstrip("\n").split("\t")
            key = parts[0][4:]
            rec = {}
            rec["kind"] = parts[1]
            rec["name"] = parts[2]
            rec["span"] = parts[3]
            for x in parts[4:]:
                if "=" in x:
                    k, v = x.split("=", 1)
                    rec[k] = v
            d[key].append(rec)
    return d


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    g = load(sys.argv[1])
    o = load(sys.argv[2])
    show_all = "--all" in sys.argv
    print("LHS = GOLDEN (Surelog)   RHS = OURS")
    keys = sorted(set(g) | set(o))
    tally = defaultdict(int)
    rows = []
    for k in keys:
        gl = sorted(g.get(k, []), key=lambda r: r["span"])
        ol = sorted(o.get(k, []), key=lambda r: r["span"])
        n = max(len(gl), len(ol))
        for i in range(n):
            gr = gl[i] if i < len(gl) else None
            orr = ol[i] if i < len(ol) else None
            if gr and orr:
                if gr["kind"] != orr["kind"]:
                    v = "SHAPE"
                elif gr["name"] != orr["name"]:
                    v = "NAME"
                else:
                    v = "agree"
            elif gr:
                v = "GONLY"
            else:
                v = "OONLY"
            tally[v] += 1
            if v != "agree" or show_all:
                def f(r):
                    if not r:
                        return "-"
                    return "%s '%s' %s pfx=%s tgt=%s own=%s RN=%s" % (
                        r["kind"], r["name"], r["span"], r.get("prefix", "-"),
                        r.get("tgt", "-"), r.get("owner", "-"),
                        r.get("RETNAME", "?"))
                rows.append("%-6s %-28s  G: %s\n%41s O: %s" %
                            (v, k, f(gr), "", f(orr)))
    for r in rows:
        print(r)
    print("---- TOTALS ----")
    for k in ("agree", "SHAPE", "NAME", "GONLY", "OONLY"):
        print("%-6s %d" % (k, tally[k]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
