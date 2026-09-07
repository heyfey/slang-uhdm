#!/usr/bin/env bash
# r10uvm192repro/cen192.sh — THE CORPUS CENSUS DRIVER.  MEASUREMENT ONLY; the
# official uhdm-cmp is the judge.  LHS is ALWAYS golden (Surelog).
#
# For every database in a workdir it runs `ct192cen` on OURS and on the GOLDEN
# that row actually used — found through the row's OWN `cmds.txt`, never
# guessed from a test name, so a row whose golden is a different tree
# (BuildUVMPkg is the 1800.2 pp_output tree, the other UVM rows are uvm-1.2)
# cannot be scored against the wrong file.
#
# Output: `<prefix>.<mode>.<test>.g` and `.o` census files, plus a manifest.
# `score192.py` does the multiset join and the verdict.
#
# Fenced test names are read out of `canaudit.sh`'s `FENCED=` line and redacted
# in every path this script writes.  Nothing here dispatches a test.
#
#   usage: CEN=<ct192cen> cen192.sh <workdir> <out dir> [test-name-filter ...]
set -u
WD=${1:?workdir}
OUTD=${2:?out dir}
shift 2 || true
CEN=${CEN:?path to ct192cen}
[ -x "$CEN" ] || { echo "FATAL: no ct192cen at $CEN"; exit 3; }
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
HERE=$(cd "$(dirname "$0")" && pwd)
FENCED=$(sed -n 's/^FENCED="\(.*\)"$/\1/p' "$HERE/canaudit.sh")
[ -n "$FENCED" ] || { echo "FATAL: no fence list in canaudit.sh"; exit 3; }
mkdir -p "$OUTD" || exit 3
MAN="$OUTD/manifest.txt"
: > "$MAN"
n=0; nog=0
for mode in default testflags; do
  [ -d "$WD/$mode" ] || continue
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    t=$(basename "$d")
    base=${t%-*}
    if [ $# -gt 0 ]; then
      keep=0
      for f in "$@"; do [ "$base" = "$f" ] && keep=1; done
      [ "$keep" = 1 ] || continue
    fi
    nm=$t
    for fn in $FENCED; do
      case $t in "$fn"-*) nm=FENCED-${t##*-} ;; esac
    done
    [ -f "$d/slang.uhdm" ] || { echo "NO-OURS $mode/$nm" >> "$MAN"; continue; }
    G=$(sed -n 's/.*golden cache hit \([^)]*\).*/\1/p' "$d/cmds.txt" 2>/dev/null)/golden.uhdm
    if [ ! -f "$G" ]; then
      echo "NO-GOLDEN $mode/$nm" >> "$MAN"; nog=$((nog+1)); continue
    fi
    "$CEN" "$G"            "$mode/$nm" > "$OUTD/$mode.$nm.g" 2>/dev/null
    "$CEN" "$d/slang.uhdm" "$mode/$nm" > "$OUTD/$mode.$nm.o" 2>/dev/null
    echo "PAIR $mode/$nm golden=$G" >> "$MAN"
    n=$((n+1))
  done
done
echo "-- pairs=$n no-golden=$nog" | tee -a "$MAN"
