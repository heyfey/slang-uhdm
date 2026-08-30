#!/usr/bin/env python3
"""r10uvm166 — the DECLARATION-KIND census join.  MEASUREMENT ONLY.
LHS/G is ALWAYS golden (Surelog); RHS/O is ALWAYS ours.

MULTISET join (keys DO collide — two declarators of one declaration share a
span in some shapes), never a last-writer dict.  Rows are keyed on what BOTH
sides can spell: SITE, VIEW, OWNER, LINE:COL, NAME.  The compared payload is
VK (the declaration's own UHDM kind), TSK/TSN (the bound typespec's kind and
name), TSI (its vpiInstance's name) and TSLC (its span).

usage: join166.py <g.tsv> <o.tsv> [--only-diff] [--filter <substr>]
"""
import sys, collections

COLS = []
NAMED = {"VK": 8, "PK": 9, "TSK": 10, "TSN": 11, "TSI": 12, "TSLC": 13}

DECL = {"LOCAL", "RET", "PROP", "VAR", "FORMAL", "MEMBER", "PARAM", "TPARAM"}

def load(p):
    m = collections.defaultdict(list)
    for ln in open(p):
        f = ln.rstrip("\n").split("\t")
        if len(f) < 14 or f[1] not in DECL:
            continue
        key = (f[1], f[2], f[5], f[6], f[7])
        cols = COLS or list(range(8, 14))
        m[key].append(tuple(f[i] for i in cols))     # VK PK TSK TSN TSI TSLC
    return m

def main():
    global COLS
    args0 = sys.argv[3:]
    if "--cols" in args0:
        COLS = [NAMED[c] for c in args0[args0.index("--cols") + 1].split(",")]
    g = load(sys.argv[1]); o = load(sys.argv[2])
    args = sys.argv[3:]
    only = "--only-diff" in args
    asset = "--set" in args      # compare the SET, so pure MULTIPLICITY
                                 # artefacts (one object listed twice in our
                                 # DB) are not scored as kind disagreements
    filt = args[args.index("--filter")+1] if "--filter" in args else None
    shared = same = diff = gonly = oonly = 0
    for k in sorted(set(g) | set(o)):
        gl = sorted(g.get(k, [])); ol = sorted(o.get(k, []))
        if asset:
            gl = sorted(set(gl)); ol = sorted(set(ol))
        if filt and filt not in "\t".join(k):
            continue
        if not ol:
            gonly += len(gl)
            print("ONLY-G\t" + "\t".join(k) + "\t" + str(gl)); continue
        if not gl:
            oonly += len(ol)
            print("ONLY-O\t" + "\t".join(k) + "\t" + str(ol)); continue
        shared += 1
        if gl == ol:
            same += 1
            if not only:
                print("SAME\t" + "\t".join(k) + "\t" + str(gl))
        else:
            diff += 1
            print("DIFF\t" + "\t".join(k) + "\tG=" + str(gl) + "\tO=" + str(ol))
    print(f"-- shared={shared} same={same} DIFF={diff} ONLY-G={gonly} ONLY-O={oonly}")

main()
