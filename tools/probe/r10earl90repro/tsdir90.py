#!/usr/bin/env python3
"""r10earl90 — THE DIRECTION SCORER.  MEASUREMENT ONLY.

For every cell whose PAYLOAD CHANGED between the pristine and the patched
census of one arm (or one database), count the scored fields that agree with
golden BEFORE and AFTER, and classify:

    TO-GOLDEN     the patched payload agrees with golden in strictly MORE
                  fields than the pristine one did, and in no fewer
    EXACT         and it now equals golden in every scored field
    AWAY          the patched payload agrees in FEWER fields, or it changed a
                  field that was already right   <- MUST BE 0
    NEUTRAL       the same number of fields agree, differently

A cell whose key exists on one side only is reported separately; the join is a
MULTISET.

  usage: tsdir90.py <g.rows> <o.rows> <q.rows> [--cells]
"""
import sys, collections

SCORED = ["KIND","NAME","SZ","VAL","CT","DEC","TS","TSN","TSSG","TSVL",
          "TSRG","TSAL","TSIN","TSCE","HPNM","CS","IPT"]

def load(p):
    d = collections.defaultdict(list)
    for line in open(p):
        line = line.rstrip("\n")
        if "\t||\t" not in line:
            continue
        k, v = line.split("\t||\t", 1)
        d[k].append(v)
    for k in d:
        d[k].sort()
    return d

def f(p):
    r = {}
    for x in p.split("\t"):
        if "=" in x:
            a, b = x.split("=", 1)
            r[a] = b
    return r

def agree(a, b):
    return sum(1 for k in SCORED if a.get(k) == b.get(k))

def main():
    g, o, q = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
    cells = "--cells" in sys.argv
    T = collections.Counter()
    for k in sorted(set(o) | set(q)):
        ol, ql, gl = o.get(k, []), q.get(k, []), g.get(k, [])
        n = max(len(ol), len(ql))
        for i in range(n):
            ov = ol[i] if i < len(ol) else None
            qv = ql[i] if i < len(ql) else None
            if ov == qv:
                T["UNCHANGED"] += 1
                continue
            T["CHANGED"] += 1
            if i >= len(gl):
                T["CHANGED-NO-GOLDEN"] += 1
                if cells:
                    print("NO-GOLDEN %s\n   O %s\n   Q %s" % (k, ov, qv))
                continue
            gv = gl[i]
            gf, of, qf = f(gv), f(ov or ""), f(qv or "")
            a0, a1 = agree(gf, of), agree(gf, qf)
            if a1 > a0:
                v = "EXACT" if a1 == len(SCORED) else "TO-GOLDEN"
            elif a1 < a0:
                v = "AWAY"
            else:
                v = "NEUTRAL"
            # a field that was ALREADY right and is now wrong is AWAY even when
            # the total went up
            for fld in SCORED:
                if of.get(fld) == gf.get(fld) and qf.get(fld) != gf.get(fld):
                    v = "AWAY"
            T[v] += 1
            if cells and (v != "TO-GOLDEN" or "--all" in sys.argv):
                print("%-9s %s\n   G %s\n   O %s\n   Q %s" %
                      (v, k.replace("\t", " "), gv, ov, qv))
    for k in ("CHANGED", "EXACT", "TO-GOLDEN", "NEUTRAL", "AWAY",
              "CHANGED-NO-GOLDEN", "UNCHANGED"):
        print("%-18s %d" % (k, T[k]))

main()
