#!/usr/bin/env python3
"""r10earl83 — THE WRITTEN-CAST SCORER.  MEASUREMENT ONLY.

Joins the golden and ours rows that `cen83.sh` produced, as a MULTISET (a
last-writer dict silently drops colliding rows — a trap this campaign has
already paid for), and splits the cells four ways:

    BOTH-SAME     the key exists on both sides and every scored field agrees
    MOVED-WRONG   the key exists on both sides and a scored field differs
    OURS-ONLY     we put an object at that cast site and golden put none
    GOLDEN-ONLY   golden put an object there and we put none

KEY   SPAN + CTX + PORTPAR + CALLARG + PSBOUND     (never scored)
SCORED  KIND OPT NOPS SZ VAL CT DEC TS TSV TSN OP0

The payload carries NO span-derived field beyond the key: earl60's attrv60
lesson is that a span-carrying payload hides a real flip inside a cell that
already differs.

  usage: score83.py <cendir> [--family] [--detail <substr>]
         --family   print ONLY the REDUCED family: an ELABORATED port High_conn
                    (PORTPAR=module_inst) where golden holds a `constant` and we
                    hold a `vpiCastOp` operation — the population this pass's law
                    claims, listed per database BY NAME so the movers are
                    predicted before any patched sweep is read.
"""
import sys, os, collections

def load(path):
    rows = []
    if not os.path.exists(path):
        return rows
    with open(path) as f:
        for line in f:
            line = line.rstrip("\n")
            if not line or "\t||\t" not in line:
                continue
            k, p = line.split("\t||\t", 1)
            rows.append((k, p))
    return rows

def join(g, o):
    gm = collections.Counter()
    om = collections.Counter()
    for k, p in g: gm[(k, p)] += 1
    for k, p in o: om[(k, p)] += 1
    same = gm & om
    grest = gm - same
    orest = om - same
    # second pass: same KEY, different payload -> MOVED-WRONG
    gk = collections.defaultdict(list)
    ok = collections.defaultdict(list)
    for (k, p), n in grest.items(): gk[k] += [p] * n
    for (k, p), n in orest.items(): ok[k] += [p] * n
    moved, gonly, oonly = [], [], []
    for k in set(gk) | set(ok):
        gl, ol = sorted(gk.get(k, [])), sorted(ok.get(k, []))
        n = min(len(gl), len(ol))
        for i in range(n): moved.append((k, gl[i], ol[i]))
        for i in range(n, len(gl)): gonly.append((k, gl[i]))
        for i in range(n, len(ol)): oonly.append((k, ol[i]))
    return sum(same.values()), moved, gonly, oonly

def fields(p):
    d = {}
    for f in p.split("\t"):
        if "=" in f:
            a, b = f.split("=", 1)
            d[a] = b
    return d

def main():
    cd = sys.argv[1]
    family = "--family" in sys.argv
    idx = [l.strip() for l in open(os.path.join(cd, "INDEX.txt")) if l.strip()]
    T = collections.Counter()
    famrows = collections.defaultdict(list)
    for tag in idx:
        g = load(os.path.join(cd, tag + ".gold"))
        o = load(os.path.join(cd, tag + ".ours"))
        ns, moved, gonly, oonly = join(g, o)
        T["BOTH-SAME"] += ns
        T["MOVED-WRONG"] += len(moved)
        T["GOLDEN-ONLY"] += len(gonly)
        T["OURS-ONLY"] += len(oonly)
        T["DB"] += 1
        for k, gp, op in moved:
            kf, gf, of = fields(k), fields(gp), fields(op)
            if (kf.get("CTX") == "PORTHC" and kf.get("PORTPAR") == "module_inst"
                    and gf.get("KIND") == "constant"
                    and of.get("KIND") == "operation" and of.get("OPT") == "67"):
                T["FAMILY"] += 1
                famrows[tag].append((k, gp, op))
            elif gf.get("KIND") == "constant" and of.get("KIND") == "operation" \
                    and of.get("OPT") == "67":
                T["REDUCED-ELSEWHERE"] += 1
                famrows["!" + tag].append((k, gp, op))
    if family:
        for tag in sorted(famrows):
            for k, gp, op in famrows[tag]:
                print("%s\t%s\t||G\t%s\t||O\t%s" % (tag, k, gp, op))
    for k in ("DB", "BOTH-SAME", "MOVED-WRONG", "GOLDEN-ONLY", "OURS-ONLY",
              "FAMILY", "REDUCED-ELSEWHERE"):
        print("%-18s %d" % (k, T[k]), file=sys.stderr)

main()
