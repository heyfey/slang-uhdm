#!/usr/bin/env python3
"""r10v205 — the STRICT census scorer (adversarial verification of r10uvm205).

MEASUREMENT ONLY; the official `uhdm-cmp` is the sole judge.

WHY THIS EXISTS.  `r10uvm205repro/score205.py` scores the payload
`(kind, VpiName, alias VpiName)` only.  The generated
`~/git-repos/UHDM/build/generated/src/typespec.cpp` `Compare` reads
`Typedef_alias` (line 93) and then `Instance` (line 94), so `vpiInstance` is a
JUDGE-VISIBLE field of exactly the objects this law re-points, and the pass's
AWAY-GOLDEN 0 claim was measured with it excluded.  `ct205cen --raw` already
records `inst` and `ainst`; this scorer puts them back in the payload.

usage: v205score.py <raw.pristine.txt> <raw.patched.txt> [--show] [--filter=SUB]
                    [--cols=3|5]      (5 = +inst,+ainst; the default)
"""
import sys
import collections


def load(path, ncols):
    gold, ours = {}, {}
    for line in open(path):
        if not line.startswith("RAW\t"):
            continue
        f = line.rstrip("\n").split("\t")
        # RAW side key kind ts alias inst ainst refId tsId chain
        side, key = f[1], f[2]
        payload = tuple(f[3:3 + ncols])
        (gold if side == "GOLD" else ours)[key] = payload
    return gold, ours


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    show = "--show" in sys.argv
    ncols = 5
    filt = None
    for a in sys.argv[1:]:
        if a.startswith("--filter="):
            filt = a[len("--filter="):]
        if a.startswith("--cols="):
            ncols = int(a[len("--cols="):])
    gA, oA = load(sys.argv[1], ncols)
    gB, oB = load(sys.argv[2], ncols)
    if gA != gB:
        print("FATAL: golden differs between the two runs")
        return 3
    keys = set(gA) & set(oA) & set(oB)
    if filt:
        keys = {k for k in keys if filt in k}
    tab = collections.Counter()
    for k in sorted(keys):
        a_ok, b_ok = gA[k] == oA[k], gB[k] == oB[k]
        if a_ok and b_ok:
            v = "AGREE"
        elif not a_ok and b_ok:
            v = "TO-GOLDEN"
        elif a_ok and not b_ok:
            v = "AWAY-GOLDEN"
        elif oA[k] != oB[k]:
            v = "MOVED-WRONG"
        else:
            v = "STILL-WRONG"
        tab[v] += 1
        if show and v in ("AWAY-GOLDEN", "MOVED-WRONG"):
            print("%-12s %s\n     gold=%s\n     pris=%s\n     patd=%s"
                  % (v, k, gA[k], oA[k], oB[k]))
    og = len((set(gA) - set(oA)) | (set(gB) - set(oB)))
    oo = len((set(oA) - set(gA)) | (set(oB) - set(gB)))
    print("cols=%d TO-GOLDEN %d  AWAY-GOLDEN %d  MOVED-WRONG %d  STILL-WRONG %d"
          "  AGREE %d  (one-sided: only-golden %d only-ours %d)"
          % (ncols, tab["TO-GOLDEN"], tab["AWAY-GOLDEN"], tab["MOVED-WRONG"],
             tab["STILL-WRONG"], tab["AGREE"], og, oo))
    return 0


if __name__ == "__main__":
    sys.exit(main())
