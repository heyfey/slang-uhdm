#!/usr/bin/env python3
"""r10uvm129 — multiset golden-vs-ours(-vs-patched) join over cen129 CELL rows.

LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY — the official uhdm-cmp is the judge.

  usage: score129.py <golden.cen> <ours.cen> [patched.cen]

Key   = SITE + the array_var field (kind|name|span|arrayType).  No ids, no
        file, no view flag.  Multiset join (a key can repeat).
Payload fields: ARRTS  ELEMVAR  ELEMTS  shared  elevts_nrefs

THE LAW FIELD is the ELEMENT VARIABLE's `sgn=`.  Two scores are reported.

1. LAW SCORE, on that field alone:
     LAW-WRONG   pristine cells whose element-variable vpiSigned != golden's
     LAW-FIXED / LAW-BROKE / LAW-STILL-WRONG / LAW-SAME-OK  (with a patched file)
2. COLLATERAL, on EVERY OTHER field: any pristine->patched change outside the
   law field is listed and counted.  A clean pass reports COLLATERAL=0.

RESIDUE families, reported but not this law's:
     TSKIND   the element typespec's CLASS/NAME disagrees (uvm126 residue 1)
     TSSPAN   only typespec SPANS disagree (dump-only: no generated Compare
              reads VpiFile/VpiLineNo/VpiColumnNo)
     VARKIND  the element variable's CLASS disagrees
"""
import sys, collections

FIELDS = ["ARRTS", "ELEMVAR", "ELEMTS", "shared", "nrefs"]

def load(p):
    rows = collections.defaultdict(list)
    for ln in open(p):
        if not ln.startswith("CELL\t"):
            continue
        f = ln.rstrip("\n").split("\t")
        rows[(f[1], f[2])].append(tuple(f[3:]))
    for k in rows:
        rows[k].sort()
    return rows

def part(s, pfx):
    for p in s.split("|"):
        if p.startswith(pfx):
            return p
    return pfx + "?"

def sgn(cell):    return part(cell[1], "sgn=")
def varkind(cell): return cell[1].split("|")[0]
def tskind(cell):  return cell[2].split("|")[0]
def tsname(cell):  return cell[2].split("|")[1] if "|" in cell[2] else ""

def strip_span(s):
    return "|".join(p for p in s.split("|")
                    if not (len(p) > 2 and p[0].isdigit() and ":" in p and "-" in p))

def blank_sgn(cell):
    """the cell with the LAW FIELD blanked, so any other change shows up"""
    ev = "|".join("sgn=*" if p.startswith("sgn=") and i == 3 else p
                  for i, p in enumerate(cell[1].split("|")))
    return (cell[0], ev) + tuple(cell[2:])

def join(a, b):
    onlyA, onlyB, both = [], [], []
    for k in sorted(set(a) | set(b)):
        ga, gb = list(a.get(k, [])), list(b.get(k, []))
        n = min(len(ga), len(gb))
        for i in range(n):
            both.append((k, ga[i], gb[i]))
        onlyA += [(k, x) for x in ga[n:]]
        onlyB += [(k, x) for x in gb[n:]]
    return both, onlyA, onlyB

def main():
    g = load(sys.argv[1]); o = load(sys.argv[2])
    p = load(sys.argv[3]) if len(sys.argv) > 3 else None
    both, og, oo = join(g, o)
    c = collections.Counter()
    pris = {}
    for k, gr, orr in both:
        pris[(k, tuple(gr))] = orr
        if sgn(gr) != sgn(orr):
            c["LAW-WRONG"] += 1
            print("LAW-WRONG\t%s\t%s\n\tG %s\n\tO %s" %
                  (k[0], k[1], " | ".join(gr), " | ".join(orr)))
        if tskind(gr) != tskind(orr) or tsname(gr) != tsname(orr):
            c["TSKIND"] += 1
        elif strip_span(gr[2]) == strip_span(orr[2]) and gr[2] != orr[2]:
            c["TSSPAN"] += 1
        if varkind(gr) != varkind(orr):
            c["VARKIND"] += 1
    print("PRIS cells=%d ONLY-GOLDEN=%d ONLY-OURS=%d %s" %
          (len(both), len(og), len(oo),
           " ".join("%s=%d" % kv for kv in sorted(c.items()))))
    if p is None:
        return
    bothp, ogp, oop = join(g, p)
    s = collections.Counter()
    for k, gr, pr in bothp:
        orr = pris.get((k, tuple(gr)))
        gs, ps = sgn(gr), sgn(pr)
        os_ = sgn(orr) if orr else None
        if os_ is None:
            s["NO-PRISTINE-TWIN"] += 1
        elif os_ != gs and ps == gs:
            s["LAW-FIXED"] += 1
        elif os_ == gs and ps != gs:
            s["LAW-BROKE"] += 1
            print("LAW-BROKE\t%s\t%s\n\tG %s\n\tO %s\n\tP %s" %
                  (k[0], k[1], " | ".join(gr), " | ".join(orr), " | ".join(pr)))
        elif ps != gs:
            s["LAW-STILL-WRONG"] += 1
            print("LAW-STILL-WRONG\t%s\t%s\n\tG %s\n\tP %s" %
                  (k[0], k[1], " | ".join(gr), " | ".join(pr)))
        else:
            s["LAW-SAME-OK"] += 1
        if orr and blank_sgn(orr) != blank_sgn(pr):
            s["COLLATERAL"] += 1
            print("COLLATERAL\t%s\t%s\n\tO %s\n\tP %s" %
                  (k[0], k[1], " | ".join(orr), " | ".join(pr)))
    print("PATCHED cells=%d ONLY-GOLDEN=%d ONLY-PATCHED=%d %s COLLATERAL=%d" %
          (len(bothp), len(ogp), len(oop),
           " ".join("%s=%d" % kv for kv in sorted(s.items()) if kv[0] != "COLLATERAL"),
           s["COLLATERAL"]))

main()
