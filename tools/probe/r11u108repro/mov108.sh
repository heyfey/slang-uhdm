#!/bin/bash
# mov108.sh <bnd-out-root> <tagA>=<binA> <tagB>=<binB> [probe-root]
# For every MOVED arm of a bnd108 run: re-run binA (nondeterminism self-check),
# build golden with the pinned Surelog (-parse -nobuiltin -nocache -sv <file>),
# score uhdm-cmp lines/heads for A and B, and count the order-blind,
# path-normalised whole-dump diff A->B plus the lines that are NOT the law's
# kind flip (logic_var/bit_var -> packed_array_var).
OUT=${1:?}; A=${2:?}; B=${3:?}; ROOT=${4:-$(cd "$(dirname "$0")/.." && pwd)}
ta=${A%%=*}; ba=${A#*=}; tb=${B%%=*}; bb=${B#*=}
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
n(){ timeout 600 $D "$1" 2>&1 | tail -n +2 | sed -E 's#/tmp/[A-Za-z0-9_./-]*/##g' | sort; }
grep '^MOVED' "$OUT/result.txt" | awk '{print $2}' | sort | while read -r rel; do
  d=$(dirname "$rel"); f=$(basename "$rel"); key=$(echo "$rel" | sed 's#^\./##; s#/#__#g'); w="$OUT/arms/$key"
  (cd "$ROOT/$d" && timeout 120 "$ba" "$f" --single-unit --nobuiltin -o "$w/${ta}2.uhdm" </dev/null >/dev/null 2>&1)
  cmp -s "$w/$ta.uhdm" "$w/${ta}2.uhdm" && nd=det || nd=NONDET
  if [ ! -f "$w/gold.uhdm" ]; then
    rm -rf "$w/gold"; mkdir -p "$w/gold"
    (cd "$ROOT/$d" && timeout 300 "$SL" -parse -nobuiltin -nocache -sv "$f" -mt 0 -mp 0 -o "$w/gold" </dev/null >"$w/gold/log" 2>&1)
    g=$(ls "$w"/gold/slpp_*/*.uhdm 2>/dev/null | head -1); [ -n "$g" ] && cp "$g" "$w/gold.uhdm"
  fi
  if [ -f "$w/gold.uhdm" ]; then
    $CMP "$w/gold.uhdm" "$w/$ta.uhdm" > "$w/$ta.cmp" 2>&1; $CMP "$w/gold.uhdm" "$w/$tb.uhdm" > "$w/$tb.cmp" 2>&1
    sa="$(wc -l < "$w/$ta.cmp")/$(grep -c '^LHS:' "$w/$ta.cmp"; true)"; sb="$(wc -l < "$w/$tb.cmp")/$(grep -c '^LHS:' "$w/$tb.cmp"; true)"
  else sa=NOGOLD; sb=NOGOLD; fi
  diff <(n "$w/$ta.uhdm") <(n "$w/$tb.uhdm") > "$w/obl.diff"
  tot=$(grep -c '^[<>]' "$w/obl.diff"; true)
  other=$(grep '^[<>]' "$w/obl.diff" | sed -E 's/^[<>] *//; s/\\_(logic|bit|packed_array)_var: /\\_VAR: /' | sort | uniq -u | wc -l)
  echo "$rel $nd cmp:$ta=$sa $tb=$sb obl=$tot nonkind=$other"
done
