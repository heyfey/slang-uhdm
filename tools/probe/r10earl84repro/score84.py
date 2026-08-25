#!/usr/bin/env python3
"""r10earl84 — THE SELECT-BOUND SCORER.  MEASUREMENT ONLY.

Joins the golden and ours rows `cen84.sh` produced as a MULTISET (a
last-writer dict silently drops colliding rows — a trap this campaign has
already paid for), and splits every cell four ways:

    BOTH-SAME     the key exists on both sides and every scored field agrees
    MOVED-WRONG   the key exists on both sides and a scored field differs
    OURS-ONLY     we hold a select there and golden holds none
    GOLDEN-ONLY   golden holds a select there and we hold none

KEY     SPAN + SLOT + SEL + INHP + CTX + PORTPAR + CALLARG + PSBOUND  (never scored)
SCORED  KIND NAME SZ VAL CT DEC TS TSN HPNM CS IPT

The payload carries NO span-derived field beyond the key (earl60's attrv60
lesson: a span-carrying payload hides a real flip inside a cell that already
differs).

  usage: score84.py <cendir> [--family] [--detail <substr>] [--allmoved]
         --family  print ONLY THIS LAW'S FIRE-SET: golden a folded `constant`,
                   ours a `ref_obj`, in an ELABORATED port High_conn
                   (CTX=PORTHC PORTPAR=module_inst CALLARG=0), split by INHP
                   and by SLOT, listed per database BY NAME so the movers are
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
    gm = collections.Counter(); om = collections.Counter()
    for k, p in g: gm[(k, p)] += 1
    for k, p in o: om[(k, p)] += 1
    same = gm & om
    grest = gm - same; orest = om - same
    gk = collections.defaultdict(list); ok = collections.defaultdict(list)
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
    allmoved = "--allmoved" in sys.argv
    det = None
    if "--detail" in sys.argv:
        det = sys.argv[sys.argv.index("--detail") + 1]
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
            elabhc = (kf.get("CTX") == "PORTHC"
                      and kf.get("PORTPAR") == "module_inst"
                      and kf.get("CALLARG") == "0")
            fold = gf.get("KIND") == "constant" and of.get("KIND") == "ref_obj"
            if fold and elabhc:
                bucket = "FAMILY-HP" if kf.get("INHP") == "1" else "FAMILY-BARE"
                T[bucket] += 1
                T[bucket + ":" + kf.get("SLOT", "?")] += 1
                famrows[tag].append((k, gp, op))
            elif fold:
                T["FOLD-ELSEWHERE"] += 1
                T["FOLD-ELSEWHERE:" + kf.get("CTX", "?") + "/" +
                  kf.get("PORTPAR", "-")] += 1
                famrows["!" + tag].append((k, gp, op))
            if allmoved:
                print("MOVED\t%s\t%s\t||G\t%s\t||O\t%s" % (tag, k, gp, op))
            if det and det in k:
                print("DET\t%s\t%s\t||G\t%s\t||O\t%s" % (tag, k, gp, op))
    if family:
        for tag in sorted(famrows):
            for k, gp, op in famrows[tag]:
                print("%s\t%s\t||G\t%s\t||O\t%s" % (tag, k, gp, op))
    for k in sorted(T):
        print("%-34s %d" % (k, T[k]), file=sys.stderr)

main()
