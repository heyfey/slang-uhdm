#!/usr/bin/env bash
# r10uvm184repro/predict184.sh — THE A-PRIORI MOVER PREDICTION, from PRISTINE
# BYTES ALONE.  MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is
# ALWAYS ours.
#
# For every row of a COMPLETED PRISTINE sweep workdir it reads the row's own
# golden (out of the row's `cmds.txt`, so the wrong golden cannot be compared)
# and the row's pristine database, runs `ct184mfc` on both, and asks the LAW's
# question of the PRISTINE pair:
#
#   does any method-call ARGUMENT key exist that GOLDEN binds to the RECEIVER
#   and the PRISTINE database does not?
#
# A row with no such key CANNOT move — the law only ever rewrites such an
# argument's `vpiActual`.  A row with one is PREDICTED to move.  The predicate
# is a SUPERSET of the law's own gate (it does not test the wildcard-import
# clone gate, which is not readable off a database), so the prediction can
# over-name but never under-name.
#
#   usage: predict184.sh <PRISTINE workdir> <out.txt>
# The out file's PREDICT lines are the prediction; LISTED/PROCESSED/NOGOLDEN
# are asserted so a row that was silently skipped can never read as "cannot
# move".
set -u
WD=${1:?pristine workdir}
OUT=${2:?out file}
CEN=${CT184MFC:-/tmp/r10uvm184_bin/ct184mfc}
[ -x "$CEN" ] || { echo "FATAL: no ct184mfc at $CEN"; exit 3; }
: > "$OUT"
listed=0; processed=0; nogolden=0; predicted=0
while IFS= read -r db <&3; do
  listed=$((listed+1))
  d=$(dirname "$db")
  rel=${d#$WD/}
  C="$d/cmds.txt"
  G=""
  [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ]; then
    echo "NOGOLDEN $rel" >> "$OUT"; nogolden=$((nogolden+1)); continue
  fi
  T=$(mktemp -d /tmp/r10uvm184_pred_XXXXXX)
  "$CEN" "$G"  > "$T/g.txt" 2>/dev/null
  "$CEN" "$db" > "$T/o.txt" 2>/dev/null
  n=$(python3 - "$T/g.txt" "$T/o.txt" <<'PY'
import sys
from collections import defaultdict
def load(p):
    r=defaultdict(list)
    for ln in open(p):
        if ln.startswith('ROWS'): continue
        f=ln.split()
        if f[4]=='arg-1': continue          # the Prefix ref, not an argument
        r[(f[0],f[1],f[2],f[3],f[4])].append(f[-1])
    return r
g=load(sys.argv[1]); o=load(sys.argv[2])
n=0
for k,v in g.items():
    if 'SAME-AS-RECEIVER' not in v: continue
    if sorted(v)!=sorted(o.get(k,[])): n+=1
print(n)
PY
)
  rm -rf "$T"
  processed=$((processed+1))
  if [ "${n:-0}" -gt 0 ]; then
    echo "PREDICT $rel cells=$n" >> "$OUT"; predicted=$((predicted+1))
  fi
done 3< <(find "$WD" -name slang.uhdm | sort)
echo "LISTED=$listed PROCESSED=$processed NOGOLDEN=$nogolden PREDICTED=$predicted" >> "$OUT"
tail -1 "$OUT"
