#!/usr/bin/env python3
"""r10uvm154 — join the enum_const census.  MEASUREMENT ONLY.

Reads cen154.sh's TSV and does a MULTISET join per (mode,test) cell on the key

    (owner-typespec-name, const-name, line:col-endln:endcol)

keeping BOTH views under the same key (a per-view flip therefore cannot hide
inside a last-writer dict — RESUME.md §9's census trap).  The payload compared
is (VpiValue, VpiDecompile, VpiSize): exactly the three fields enum_const's
generated Compare reads beyond VpiName.

Verdicts per key-instance:  SAME / WRONG (both sides, payload differs) /
ONLY-GOLDEN / ONLY-OURS.
"""
import sys, collections

def load(path):
    per = collections.defaultdict(lambda: collections.defaultdict(list))
    for line in open(path, errors="replace"):
        f = line.rstrip("\n").split("\t")
        if len(f) != 4 or not f[3].startswith("EC|"): continue
        mode, test, side, row = f
        p = row.split("|")
        # EC|owner|name|loc|value|decompile|size|basekind|basename
        if len(p) < 9: continue
        key = (p[1], p[2], p[3])
        payload = (p[4], p[5], p[6])
        extra = (p[7], p[8])
        per[(mode, test)][(side, key)].append((payload, extra))
    return per

def main():
    per = load(sys.argv[1])
    onlyname = sys.argv[2] if len(sys.argv) > 2 else None
    tot = collections.Counter()
    wrong = collections.Counter()
    wrongdetail = collections.Counter()
    onlyg = collections.Counter(); onlyo = collections.Counter()
    for cell, d in sorted(per.items()):
        # A cell with NO `O` side at all is a SLANG_REJECT row: golden exists,
        # we produced no database.  Counting its consts as ONLY-GOLDEN would
        # bury the real one-sided set under ~159k phantoms (RESUME.md §9's
        # NODEDUP trap), so comparable cells only.
        if not any(s == "O" for (s, k) in d):
            tot["CELL-NO-OURS"] += 1
            continue
        keys = set(k for (s, k) in d)
        for k in keys:
            g = list(d.get(("G", k), []))
            o = list(d.get(("O", k), []))
            gm = collections.Counter(x[0] for x in g)
            om = collections.Counter(x[0] for x in o)
            same = gm & om
            tot["SAME"] += sum(same.values())
            gl = gm - same; ol = om - same
            gv = sorted(gl.elements()); ov = sorted(ol.elements())
            n = min(len(gv), len(ov))
            for i in range(n):
                tot["WRONG"] += 1
                ex = (g[0][1] if g else ("-", "-"))
                wrong[(k[0], k[1], gv[i], ov[i], ex[0])] += 1
                wrongdetail[(gv[i], ov[i], ex[0])] += 1
            tot["ONLY-GOLDEN"] += len(gv) - n
            tot["ONLY-OURS"] += len(ov) - n
            for i in range(n, len(gv)):
                onlyg[(k[0], k[1], gv[i])] += 1
            for i in range(n, len(ov)):
                onlyo[(k[0], k[1], ov[i])] += 1
    print("TOTALS", dict(tot))
    print()
    print("=== WRONG cells, grouped by (owner, name, golden-payload, our-payload, base-kind)")
    for (own, nm, gv, ov, bk), c in sorted(wrong.items(), key=lambda x: -x[1]):
        print("%5d  %-46s %-22s G%s  O%s  base=%s" % (c, own[-46:], nm, gv, ov, bk))
    print()
    print("=== ONLY-OURS (we emit a const golden has not, at that key)")
    for (own, nm, ov), c in sorted(onlyo.items(), key=lambda x: -x[1])[:40]:
        print("%5d  %-46s %-22s O%s" % (c, own[-46:], nm, ov))
    print()
    print("=== ONLY-GOLDEN top 20 (pre-existing one-sided set, NOT this family)")
    for (own, nm, gv), c in sorted(onlyg.items(), key=lambda x: -x[1])[:20]:
        print("%5d  %-46s %-22s G%s" % (c, own[-46:], nm, gv))
    print()
    print("=== WRONG shapes, golden-payload -> our-payload x base-kind")
    for (gv, ov, bk), c in sorted(wrongdetail.items(), key=lambda x: -x[1]):
        print("%5d  G%s -> O%s  base=%s" % (c, gv, ov, bk))

main()
