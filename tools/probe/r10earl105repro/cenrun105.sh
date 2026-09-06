#!/usr/bin/env bash
# r10earl105 CORPUS CENSUS DRIVER -- MEASUREMENT ONLY.
#   cenrun104.sh <verify_golden-workdir> <outfile> [cen105-binary]
# For every <mode>/<test>-<hash>/ that holds a slang.uhdm AND names a golden
# cache entry in its OWN cmds.txt, run cen105 --all on the pair and append every
# CELL / ONLY-* row, prefixed with corpus-mode-test, to <outfile>.
# The golden path is read out of the workdir's OWN cmds.txt (never guessed); a
# missing side is printed as SKIP and COUNTED; every cen105 rc is logged.
set -u
WD=${1:?workdir}; OUT=${2:?outfile}
BIN=${3:-/tmp/r10earl105_cen105}
: > "$OUT"; : > "$OUT.log"
n=0; skip=0; bad=0
for mode in default testflags; do
  [ -d "$WD/$mode" ] || continue
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    O="$d/slang.uhdm"; C="$d/cmds.txt"
    t=$(basename "$d"); t=${t%-*}
    G=""
    [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G="$G/golden.uhdm"
    if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
      echo "SKIP $mode $t" >> "$OUT.log"; skip=$((skip+1)); continue
    fi
    "$BIN" "$G" "$O" --all --param 2>>"$OUT.log" \
      | awk -v p="$mode|$t" '/^CELL|^ONLY-/ {print p "\t" $0}' >> "$OUT"
    r=${PIPESTATUS[0]}
    echo "RC $mode $t cen=$r" >> "$OUT.log"
    [ "$r" != 0 ] && bad=$((bad+1))
    n=$((n+1))
  done
done
echo "CENSUSED=$n SKIP=$skip BADRC=$bad" | tee -a "$OUT.log"
