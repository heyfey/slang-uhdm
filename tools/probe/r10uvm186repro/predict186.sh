#!/usr/bin/env bash
# r10uvm186repro/predict186.sh — THE A-PRIORI MOVER PREDICTION, from PRISTINE
# BYTES ALONE.  MEASUREMENT ONLY; the official `uhdm-cmp` is the sole judge.
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# For every row of a COMPLETED PRISTINE sweep workdir it reads the row's own
# golden (out of the row's `cmds.txt`, so the wrong golden can never be
# compared) and the row's pristine database, runs `ct186new` on both, and asks
# the LAW's question of the PRISTINE pair:
#
#   is there a DYNAMIC-ARRAY `new[...]` ARGUMENT key that GOLDEN binds and the
#   PRISTINE database leaves BARE?
#
# A row with no such key CANNOT move — the law only ever fills such an
# argument's `vpiActual`.  A row with one is PREDICTED to move.  The predicate
# is a SUPERSET of the law's own gate (a database cannot say whether a listing
# is a wildcard-import clone, and the predicate does not test the symbol half
# either), so it can OVER-name and never UNDER-name.
#
#   usage: CT186NEW=<ct186new> predict186.sh <PRISTINE workdir> <out.txt>
# LISTED / PROCESSED / NOGOLDEN are asserted in the out file so a row that was
# silently skipped can never read as "cannot move".
set -u
WD=${1:?pristine workdir}
OUT=${2:?out file}
CEN=${CT186NEW:-/tmp/r10uvm186_bin/ct186new}
[ -x "$CEN" ] || { echo "FATAL: no ct186new at $CEN"; exit 3; }
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
  T=$(mktemp -d /tmp/r10uvm186_pred_XXXXXX)
  "$CEN" "$G"  > "$T/g.txt" 2>/dev/null
  "$CEN" "$db" > "$T/o.txt" 2>/dev/null
  n=$(python3 - "$T/g.txt" "$T/o.txt" <<'PY'
import sys
from collections import defaultdict
def load(p):
    r = defaultdict(list)
    try:
        fh = open(p)
    except OSError:
        return r
    for ln in fh:
        if ln.startswith('ROWS') or ln.startswith('RESTORE_FAIL'):
            continue
        f = ln.split()
        if len(f) < 6 or f[4] != 'DYN':
            continue          # the CLASS constructor form is not this law's
        r[(f[0], f[1], f[2], f[3])].append(f[5])
    return r
g = load(sys.argv[1]); o = load(sys.argv[2])
n = 0
for k, v in g.items():
    if all(x == 'BARE' for x in v):
        continue                       # golden binds nothing here
    mine = o.get(k, [])
    if sorted(v) == sorted(mine):
        continue                       # already agrees
    # count only keys where golden BINDS something we leave BARE
    if sum(1 for x in v if x != 'BARE') > sum(1 for x in mine if x != 'BARE'):
        n += 1
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
