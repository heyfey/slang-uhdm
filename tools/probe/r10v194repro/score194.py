#!/usr/bin/env python3
"""r10uvm194repro/score194.py — the golden x pristine [x patched] MULTISET join.

MEASUREMENT ONLY; the official uhdm-cmp is the sole judge.  LHS is ALWAYS
golden, RHS is ALWAYS ours.

Each census row is  RET|<tag>|<fn>|<line:col>|<home chain>|ACT=<payload>.
The KEY is everything up to the payload (with the side tag stripped); the
PAYLOAD is the ACT= field.  Keys COLLIDE by design — the DEF and TOP listings
of one subroutine give the same key — so the join is a MULTISET join
(collections.Counter), never a dict (RESUME §9: a last-writer dict drops rows).

verdicts per (key, payload) cell:
  AGREE        the same payload count on both sides
  TO-GOLDEN    ours moved to golden's payload between pristine and patched
  AWAY-GOLDEN  ours moved OFF golden's payload
  MOVED-WRONG  ours moved to a payload golden does not hold
  STILL-WRONG  ours disagrees before and after (untouched residue)

usage: score194.py <dir with *.g.txt/*.o.txt> [--ours2 <patched dir>]
"""
import sys, os, glob
from collections import Counter


def load(path):
    c = Counter()
    with open(path) as f:
        for ln in f:
            ln = ln.rstrip("\n")
            if not ln.startswith("RET|"):
                continue
            parts = ln.split("|")
            # RET | tag | fn | line:col | home | ACT=...
            key = "|".join([parts[2], parts[3], parts[4]])
            payload = parts[5]
            c[(key, payload)] += 1
    return c


def rowname(p):
    return os.path.basename(p)[: -len(".g.txt")]


def main():
    d1 = sys.argv[1]
    d2 = None
    if "--ours2" in sys.argv:
        d2 = sys.argv[sys.argv.index("--ours2") + 1]
    tot = Counter()
    per = {}
    for gp in sorted(glob.glob(os.path.join(d1, "*.g.txt"))):
        row = rowname(gp)
        op = os.path.join(d1, row + ".o.txt")
        if not os.path.exists(op):
            continue
        g = load(gp)
        o = load(op)
        o2 = None
        if d2:
            p2 = os.path.join(d2, row + ".o.txt")
            o2 = load(p2) if os.path.exists(p2) else Counter()
        r = Counter()
        keys = set(g) | set(o) | (set(o2) if o2 is not None else set())
        for k in keys:
            gn, on = g[k], o[k]
            if o2 is None:
                if gn == on:
                    r["AGREE"] += min(gn, on)
                elif gn > on:
                    r["GOLDEN-ONLY"] += gn - on
                else:
                    r["OURS-ONLY"] += on - gn
            else:
                n2 = o2[k]
                if on == n2:
                    if gn == on:
                        r["AGREE"] += min(gn, on)
                    elif gn > on:
                        r["STILL-MISSING"] += gn - on
                    else:
                        r["STILL-EXTRA"] += on - gn
                else:
                    # a cell that MOVED between the two of our binaries
                    if n2 == gn and on != gn:
                        r["TO-GOLDEN"] += abs(n2 - on)
                    elif on == gn and n2 != gn:
                        r["AWAY-GOLDEN"] += abs(n2 - on)
                    else:
                        r["MOVED-WRONG"] += abs(n2 - on)
        per[row] = r
        tot.update(r)
    for row in sorted(per):
        r = per[row]
        if not r:
            continue
        interesting = any(
            k not in ("AGREE",) and v for k, v in r.items())
        flag = "  <<<" if interesting else ""
        print("%-46s %s%s" % (row, dict(sorted(r.items())), flag))
    print("TOTAL", dict(sorted(tot.items())))


main()
