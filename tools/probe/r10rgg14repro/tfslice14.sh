#!/usr/bin/env bash
# r10rgg14/tfslice14.sh — compare a BOTH-mode verify_golden csv against the
# COMMITTED results/gate_uhdm2rtlil.csv, which is TESTFLAGS-ONLY.
#   usage: tfslice14.sh <both-mode.csv> [<committed-baseline.csv>]
# The baseline defaults to THIS pass's own worktree copy; pass it explicitly
# when reproducing from a different checkout.
# The committed file is read with python's csv module (never by line), because
# csv.writer defaults to \r\n and a byte-identical slice written that way once
# read as 731 differing rows (r10rgg13 § 10).
set -u
BASE=${2:-/tmp/wt_r10rgg14/results/gate_uhdm2rtlil.csv}
[ -f "$BASE" ] || { echo "FATAL: no baseline $BASE"; exit 3; }
python3 - "$1" "$BASE" <<'PY'
import csv,sys
def rd(p,mode=None):
    d={}
    with open(p,newline='') as f:
        for r in csv.DictReader(f):
            if mode and r['mode']!=mode: continue
            d[(r['name'],r['mode'])]=(r['status'],r.get('dump',''))
    return d
new=rd(sys.argv[1],'testflags'); base=rd(sys.argv[2])
n=0
for k in sorted(set(new)|set(base)):
    if new.get(k)!=base.get(k):
        n+=1; print("DIFF",k,base.get(k),"->",new.get(k))
print("committed=%d new_tf=%d differing=%d"%(len(base),len(new),n))
PY
