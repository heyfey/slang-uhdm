#!/bin/bash
# r11u3 single-row arm: re-run ONE verify_golden row with a chosen binary and
# judge it with the official uhdm-cmp (golden LHS, ours RHS).
# usage: arm.sh <workdir/mode> <binary> <outdir> <name...>
WD=$1; shift
BIN=$1; shift
OUT=$1; shift
mkdir -p "$OUT"
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
for n in "$@"; do
  d=$(ls -d "$WD"/$n-* 2>/dev/null | head -1)
  [ -z "$d" ] && { echo "$n SKIP-NODIR"; continue; }
  g=$(sed -n 's/.*golden cache hit \([^)]*\)).*/\1/p' "$d/cmds.txt")
  gu="$g/golden.uhdm"
  [ -f "$gu" ] || { echo "$n SKIP-NOGOLDEN"; continue; }
  # rebuild the slang command line with OUR binary and OUR output path
  line=$(sed -n 's/^slang: *//p' "$d/cmds.txt")
  src=$(dirname "$(ls -d "$HOME"/git-repos/uhdm2rtlil/test/$n "$HOME"/git-repos/Surelog/tests/$n "$HOME"/git-repos/Surelog/third_party/tests/$n 2>/dev/null | head -1)/x")
  out="$OUT/$n.uhdm"
  cmd=$(echo "$line" | sed -e "s#^[^ ]*#$BIN#" -e "s#-o [^ ]*#-o $out#")
  ( cd "$src" && eval "$cmd" ) > "$OUT/$n.stdout" 2>&1
  rc1=$?
  if [ ! -f "$out" ]; then echo "$n NO-DB rc=$rc1"; continue; fi
  "$CMP" "$gu" "$out" > "$OUT/$n.cmp" 2>&1
  echo "$n cmp_rc=$? heads=$(grep -c '^LHS:' "$OUT/$n.cmp") lines=$(wc -l < "$OUT/$n.cmp")"
done
