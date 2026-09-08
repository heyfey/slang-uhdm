#!/usr/bin/env python3
"""r10uvm211 — the census scorer (r10uvm207repro/score207.py, unchanged).

MEASUREMENT ONLY; the official `uhdm-cmp` is the sole judge.

Reads two `ct211cen --raw` outputs — golden-vs-PRISTINE and golden-vs-PATCHED —
and scores every key present on both sides:

  TO-GOLDEN    pristine differs from golden, patched agrees        (the law's yield)
  AWAY-GOLDEN  pristine agreed, patched differs                    (must be 0)
  MOVED-WRONG  differs on both, and the patched payload CHANGED    (must be 0)
  STILL-WRONG  differs on both, payload unchanged                  (the residue)
  AGREE        agrees on both

ONLY-GOLDEN / ONLY-OURS keys (present on one side) are reported separately and
never scored — a one-sided key is a shape difference, not a name difference.

usage: score211.py <raw.pristine.txt> <raw.patched.txt> [--show] [--filter=SUB]
"""
import sys
import collections


def load(path):
    gold, ours = {}, {}
    for line in open(path):
        if not line.startswith("RAW\t"):
            continue
        f = line.rstrip("\n").split("\t")
        # RAW side key kind ts alias inst ainst refId tsId chain
        side, key = f[1], f[2]
        payload = (f[3], f[4], f[5])          # kind, VpiName, alias VpiName
        (gold if side == "GOLD" else ours)[key] = payload
    return gold, ours


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    show = "--show" in sys.argv
    filt = None
    for a in sys.argv[1:]:
        if a.startswith("--filter="):
            filt = a[len("--filter="):]
    gA, oA = load(sys.argv[1])
    gB, oB = load(sys.argv[2])
    if gA != gB:
        # the golden side must be identical in both runs; if it is not, the two
        # runs did not read the same golden database and nothing below is valid.
        only = set(gA) ^ set(gB)
        print("FATAL: golden differs between the two runs (%d keys differ, "
              "%d one-sided)" % (sum(1 for k in set(gA) & set(gB)
                                     if gA[k] != gB[k]), len(only)))
        return 3
    keys = set(gA) & set(oA) & set(oB)
    if filt:
        keys = {k for k in keys if filt in k}
    tab = collections.Counter()
    for k in sorted(keys):
        a_ok = gA[k] == oA[k]
        b_ok = gB[k] == oB[k]
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
        if show and v not in ("AGREE",):
            print("%-12s %s\n     gold=%s\n     pris=%s\n     patd=%s"
                  % (v, k, gA[k], oA[k], oB[k]))
    og = len((set(gA) - set(oA)) | (set(gB) - set(oB)))
    oo = len((set(oA) - set(gA)) | (set(oB) - set(gB)))
    print("TO-GOLDEN %d  AWAY-GOLDEN %d  MOVED-WRONG %d  STILL-WRONG %d  "
          "AGREE %d  (one-sided: only-golden %d only-ours %d)"
          % (tab["TO-GOLDEN"], tab["AWAY-GOLDEN"], tab["MOVED-WRONG"],
             tab["STILL-WRONG"], tab["AGREE"], og, oo))
    return 0


if __name__ == "__main__":
    sys.exit(main())
