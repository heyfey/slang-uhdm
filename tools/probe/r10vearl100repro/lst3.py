#!/usr/bin/env python3
# v100 three-way listing scorer: golden vs pristine vs patched, per-key.
# key = (scope fullname, signal name); value = listing letter + object kind (+nettype for nets).
import os, subprocess, sys, collections
# Build the reader from the pass's own repro dir:
#   g++ -O1 -std=c++20 -I$HOME/.local/include -o ct100lst \
#       ../r10earl100repro/ct100lst.cpp -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lpthread
LST = os.environ.get("CT100LST", "./ct100lst")
def read(db):
    out = subprocess.run([LST, db], capture_output=True, text=True).stdout
    cells = {}
    mod = None
    for ln in out.splitlines():
        if ln.startswith("MOD "):
            mod = ln.split("|")[0][4:].strip()
        elif ln.startswith("  V ") and "<null-vector>" not in ln:
            p = ln.split()
            cells[(mod, p[3])] = "V:"+p[2]
        elif ln.startswith("  N ") and "<null-vector>" not in ln:
            p = ln.split()
            nt = [x for x in p if x.startswith("nt=")]
            cells[(mod, p[3])] = "N:"+p[2]+(" "+nt[0] if nt else "")
    return cells
g, a, b = read(sys.argv[1]), read(sys.argv[2]), read(sys.argv[3])   # golden, pris, pat
keys = set(g) | set(a) | set(b)
tog = away = still = same = 0
lines = []
for k in sorted(keys):
    gv, av, bv = g.get(k,"<absent>"), a.get(k,"<absent>"), b.get(k,"<absent>")
    if av == bv:
        if gv == av: same += 1
        else: still += 1; lines.append("STILL-WRONG %s | G=%s | P=%s" % (k, gv, av))
        continue
    if bv == gv: tog += 1; lines.append("TO-GOLDEN   %s | G=%s | pris=%s -> pat=%s" % (k, gv, av, bv))
    elif av == gv: away += 1; lines.append("AWAY-GOLDEN %s | G=%s | pris=%s -> pat=%s" % (k, gv, av, bv))
    else: lines.append("MOVED-WRONG %s | G=%s | pris=%s -> pat=%s" % (k, gv, av, bv))
print("\n".join(lines))
print("SCORE keys=%d both-right=%d TO-GOLDEN=%d AWAY-GOLDEN=%d STILL-WRONG=%d MOVED-WRONG=%d"
      % (len(keys), same, tog, away, still, len([l for l in lines if l.startswith("MOVED-WRONG")])))
