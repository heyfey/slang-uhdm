#!/usr/bin/env bash
# r10earl108 CORPUS CENSUS DRIVER -- MEASUREMENT ONLY.
#   [RAW=1] cenrun108.sh <verify_golden workdir> <out.txt>
# RAW=1 makes cen108 print the SAME rows too, which the three-way scorer needs:
# without it a row that is DIFF in one run and SAME in the other appears in only
# one file and reads as ONLY_ONE_RUN instead of TO_GOLDEN.
# For every <mode>/<test>-<hash>/ in the workdir that has BOTH a golden (read
# out of the dir's OWN cmds.txt, so the driver cannot compare against the wrong
# golden) and a slang.uhdm, run cen108 and prefix every row with the test name.
# A missing side is printed as SKIP-NOFILE and COUNTED -- a driver that reaches
# nothing must never read as perfection.  cen108's rc is recorded per cell.
set -u
WD=${1:?workdir}; OUT=${2:?out}
CEN=${CEN_BIN:-/tmp/r10earl108_cen108}
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
: > "$OUT"; : > "$OUT.status"
n=0; miss=0; bad=0
for d in "$WD"/*/*/; do
  [ -d "$d" ] || continue
  mode=$(basename "$(dirname "$d")")
  test=$(basename "$d")
  O=$d/slang.uhdm
  C=$d/cmds.txt
  G=""
  [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
    echo "SKIP-NOFILE $mode $test" >> "$OUT.status"; miss=$((miss+1)); continue
  fi
  "$CEN" "$G" "$O" "$mode" ${RAW:+--raw} 2>/dev/null | sed "s#^#$test | #" >> "$OUT"
  rc=$?
  [ $rc -ne 0 ] && { echo "CENRC=$rc $mode $test" >> "$OUT.status"; bad=$((bad+1)); }
  n=$((n+1))
done
echo "PROCESSED=$n SKIP-NOFILE=$miss CENRC-NONZERO=$bad" | tee -a "$OUT.status"
