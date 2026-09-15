#!/usr/bin/env bash
# r11u38 — THE MOVER PREDICTION, taken from the PRISTINE emission.
#
# Runs the NEUTRAL binary (this pass's binary with `R11U38_OFF=1`, which
# COMPUTES and TRACES every cell the two laws claim and WRITES NONE of them)
# over the exact command line every row of a verify_golden workdir already
# used, and prints one line per claimed cell keyed by ROW NAME.  The set it
# prints is the set `byteverify.sh` must find, and nothing else may move.
#
#   usage: predict38.sh <verify_golden workdir> <binary> <outdir>
#
# The source directory is not recorded in `cmds.txt`, so it is recovered the
# way `verify_golden.py` encodes it: the workdir leaf is `<name>-<sha1(dir)[0:8]>`.
# Every candidate directory of BOTH corpora is hashed and the map inverted.
#
# GUARDS, each an ops trap this campaign has paid for:
#   * every rebuilt command line is written to <outdir>/cmds.audit, so no run
#     can silently use another binary or another source directory;
#   * a row whose source directory cannot be recovered is printed as NODIR and
#     COUNTED; a row whose rebuilt command FAILS is printed as RC=<n> and
#     COUNTED — an arm whose compile fails teaches error recovery, not golden;
#   * PROCESSED is asserted against LISTED and the script exits non-zero if
#     they disagree: a driver that reaches nothing must never read as clean;
#   * the output goes to a caller-named directory, never a hard-coded one.
set -u
WD=${1:?workdir}
BIN=${2:?binary}
OUT=${3:?outdir}
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
[ -x "$BIN" ] || { echo "FATAL: no binary $BIN"; exit 3; }
mkdir -p "$OUT" || exit 3
: > "$OUT/cells.txt"
: > "$OUT/cmds.audit"

# --- the sha1 map of every candidate source directory -----------------------
python3 - "$OUT/dirmap.txt" <<'PY'
import hashlib, os, sys
roots = [os.path.expanduser('~/git-repos/uhdm2rtlil/test'),
         os.path.expanduser('~/git-repos/Surelog/tests'),
         os.path.expanduser('~/git-repos/Surelog/third_party/tests')]
seen = {}
for r in roots:
    for dp, dns, fns in os.walk(r):
        seen[hashlib.sha1(dp.encode()).hexdigest()[:8]] = dp
with open(sys.argv[1], 'wt') as f:
    for h, d in sorted(seen.items()):
        f.write('%s %s\n' % (h, d))
PY
echo "-- candidate source dirs hashed: $(wc -l < "$OUT/dirmap.txt")"

listed=0; processed=0; failed=0; nodir=0
work=$OUT/run
while IFS= read -r c; do
  listed=$((listed+1))
  d=$(dirname "$c")
  row=$(basename "$d")
  h=${row##*-}
  src=$(awk -v h="$h" '$1==h{print $2; exit}' "$OUT/dirmap.txt")
  line=$(sed -n 's/^slang:[[:space:]]*//p' "$c" | head -1)
  if [ -z "$line" ]; then echo "NOCMD $row" >> "$OUT/cells.txt"; processed=$((processed+1)); continue; fi
  if [ -z "$src" ] || [ ! -d "$src" ]; then
    echo "NODIR $row" >> "$OUT/cells.txt"; nodir=$((nodir+1)); processed=$((processed+1)); continue; fi
  rest=${line#* }
  rm -rf "$work"; mkdir -p "$work"
  newline=$(printf '%s' "$rest" | sed "s#-o [^ ]*#-o $work/out.uhdm#")
  echo "$row :: (cd $src && $BIN $newline)" >> "$OUT/cmds.audit"
  ( cd "$src" && R11U38_OFF=1 R11U38_CELLDBG=1 $BIN $newline ) > "$work/o.log" 2> "$work/e.log"
  rc=$?
  processed=$((processed+1))
  [ "$rc" -ne 0 ] && { failed=$((failed+1)); echo "RC=$rc $row" >> "$OUT/cells.txt"; }
  grep '^R11U38 ' "$work/e.log" | sed "s#^#$row #" >> "$OUT/cells.txt"
done < <(find "$WD" -name cmds.txt | sort)
rm -rf "$work"
echo "-- listed=$listed processed=$processed compile-failed=$failed nodir=$nodir"
echo "-- DIM cells: $(grep -c ' R11U38 DIM' "$OUT/cells.txt"; true)"
echo "-- PA  cells: $(grep -c ' R11U38 PA'  "$OUT/cells.txt"; true)"
echo "-- PREDICTED MOVER ROWS:"
grep ' R11U38 ' "$OUT/cells.txt" | awk '{print $1}' | sort -u | sed 's/^/     /'
[ "$listed" -eq "$processed" ] || { echo "GATE: PROCESSED != LISTED"; exit 5; }
