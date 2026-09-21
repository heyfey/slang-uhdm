#!/usr/bin/env python3
"""v11u79 REGRESSION DETECTOR — pristine-right -> patched-wrong, per package
-section cell.  Reads pkgscore79.py --all, whose AGREEING rows are indented
FOUR spaces and whose disagreeing rows start with '!!' + two spaces."""
import subprocess, sys, os
S = "/tmp/wt_v11u79/tools/probe/r11u79repro/pkgscore79.py"
def rows(a, t, grid):
    out = subprocess.run(["python3", S, f"{grid}/{a}/gold.{t}.dump",
                          f"{grid}/{a}/ours.{t}.dump", "--all"],
                         capture_output=True, text=True).stdout
    r = {}
    for l in out.splitlines():
        if l.startswith("PKGROWS") or "GOLDEN" in l:
            continue
        bad = l.startswith("!!")
        body = l[2:] if bad else l
        f = body.split(None, 2)
        if len(f) < 2 or not f[0].startswith("uhdm"):
            continue
        r[(f[0], f[1])] = (bad, f[2] if len(f) > 2 else "")
    return r
grid = sys.argv[1]; arms = sys.argv[2:] or sorted(os.listdir(grid))
TW = TR = REG = FIX = 0
for a in arms:
    if not os.path.exists(f"{grid}/{a}/gold.patch.dump"):
        continue
    p, q = rows(a, "pris", grid), rows(a, "patch", grid)
    reg = [k for k in q if q[k][0] and k in p and not p[k][0]]
    fix = [k for k in q if not q[k][0] and k in p and p[k][0]]
    gone = [k for k in p if k not in q]          # a row we stopped emitting
    TW += sum(1 for v in q.values() if v[0]); TR += len(reg); FIX += len(fix)
    if reg or gone:
        print(f"!! {a}: REGRESSED={len(reg)} VANISHED={len(gone)}")
        for k in reg:
            print(f"     {k[0]:<17} {k[1]:<22} pris=OK  patch={q[k][1]}")
        for k in gone:
            print(f"     {k[0]:<17} {k[1]:<22} VANISHED from patched listing")
    else:
        print(f"   {a}: wrong={sum(1 for v in q.values() if v[0])} fixed={len(fix)} REGRESSED=0")
print(f"TOTAL patched-wrong={TW} REGRESSED={TR} FIXED={FIX}")
