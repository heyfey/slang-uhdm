#!/usr/bin/env python3
"""r10uvm154 — boundary ATTRIBUTION for § enumWrittenNegDecLit154.

    attr154.py <pris.cen> <pat.cen> <pris.dmp> <pat.dmp>

Exit 0 and print `FLIPS=<n> ...` only when EVERY change in a moved database is
this law's flip, on two independent counts:

  CENSUS half — the multiset of enum_const KEYS (owner, name, loc) is
  UNCHANGED (a key that appeared or vanished is a BREACH: the law only rewrites
  three fields on an existing const), and every differing row's PATCHED payload
  is the law's own answer: value `INT:<d>` with d <= 0, `vpiSize` 64, and a
  decompile that is either `<d>` (elaborated view) or `-<digits>` (def view,
  where `-0` legitimately stays `-0` while d is `0`).

  DUMP half — every added/removed line of the whole-dump diff is an
  enum_const payload line: a value line (`|INT:`/`|UINT:`/`|BIN:`/`|HEX:`/
  `|OCT:`/`|DEC:`), a `|vpiDecompile:`, a `|vpiSize:`, or a `|vpiConstType:`.
  Any other line -- a new object, a changed parent, a moved span -- is a BREACH.

  `|vpiConstType:` is in the list because of the ALREADY-LANDED law
  § `enumSubstIntConst30`: a `constant` MINTED BY COPYING an enum_const's
  `VpiValue` takes its `vpiConstType` from that value's ENCODING PREFIX, so a
  member whose value goes `BIN:...` -> `INT:-1` drags its folded reference from
  `vpiBinaryConst` (3) to `vpiIntConst` (7).  That is a CONSEQUENCE of this law,
  not a second law, and r10earl30's own verifier arm `v7_empty.sv` is where it
  shows.  Attribution alone never licenses a move: goldscore154.sh re-scores
  EVERY moved arm against Surelog and the arm must move TOWARD golden.

MEASUREMENT ONLY; the official uhdm-cmp remains the judge.
"""
import sys, re, collections

def rows(p):
    out = collections.defaultdict(list)
    for line in open(p, errors="replace"):
        if not line.startswith("EC|"): continue
        f = line.rstrip("\n").split("|")
        if len(f) < 9: continue
        out[(f[1], f[2], f[3])].append((f[4], f[5], f[6]))
    for k in out: out[k].sort()
    return out

def main():
    pc, qc, pd, qd = sys.argv[1:5]
    A, B = rows(pc), rows(qc)
    if set(A) != set(B):
        print("BREACH census-key-set-moved added=%d removed=%d"
              % (len(set(B) - set(A)), len(set(A) - set(B))))
        return 2
    flips = 0
    for k in A:
        if len(A[k]) != len(B[k]):
            print("BREACH census-row-count %s %d->%d" % (str(k), len(A[k]), len(B[k])))
            return 2
        for a, b in zip(A[k], B[k]):
            if a == b: continue
            v, dec, sz = b
            m = re.match(r"^INT:(-?\d+)$", v)
            if not m or sz != "64":
                print("BREACH census-payload-not-law %s %s -> %s" % (str(k), a, b))
                return 2
            d = int(m.group(1))
            if d > 0:
                print("BREACH census-value-positive %s %s -> %s" % (str(k), a, b))
                return 2
            if dec != m.group(1) and not re.match(r"^-\d+$", dec):
                print("BREACH census-decompile-not-law %s %s -> %s" % (str(k), a, b))
                return 2
            flips += 1
    if flips == 0:
        print("BREACH census-frozen-while-db-moved")
        return 2
    ok = re.compile(r"^[<>]\s*\|(INT|UINT|BIN|HEX|OCT|DEC):|^[<>]\s*\|vpiDecompile:"
                    r"|^[<>]\s*\|vpiSize:|^[<>]\s*\|vpiConstType:")
    import subprocess
    dl = subprocess.run(["diff", pd, qd], capture_output=True, text=True).stdout
    # `"" in "<>"` is TRUE in Python, so a bare `l[:1] in "<>"` counts the
    # EMPTY trailing element of the split as a diff line and reports a
    # phantom `n=1 first=` breach on every genuinely clean arm.
    bad = [l for l in dl.split("\n")
           if l and l[0] in "<>" and not ok.match(l)]
    if bad:
        print("BREACH dump-line-not-law n=%d first=%s" % (len(bad), bad[0][:120]))
        return 2
    nd = len([l for l in dl.split("\n") if l and l[0] in "<>"])
    print("FLIPS=%d dumplines=%d" % (flips, nd))
    return 0

sys.exit(main())
