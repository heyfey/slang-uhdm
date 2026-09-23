#!/bin/bash
# bnd108.sh <out-root> <tagA>=<binA> <tagB>=<binB> [probe-root]
# WIDE BOUNDARY over every committed probe arm: each *.sv / *.v under the probe
# root (this pass's own dir excluded) is compiled ALONE from its own directory
# (--single-unit --nobuiltin) by both binaries; rc recorded; outputs
# byte-compared.  Scratch is keyed on the RELATIVE path.  The list is read by
# xargs from a FILE and children get </dev/null.  Prints SAME/MOVED/RCDIFF per arm and a
# PROCESSED == LISTED tally.  Parallel via xargs -P ${JOBS:-3}.
OUT=${1:?out}; A=${2:?tagA=binA}; B=${3:?tagB=binB}; ROOT=${4:-$(cd "$(dirname "$0")/.." && pwd)}
ta=${A%%=*}; ba=${A#*=}; tb=${B%%=*}; bb=${B#*=}
mkdir -p "$OUT"
LIST="$OUT/list.txt"
(cd "$ROOT" && find . \( -name '*.sv' -o -name '*.v' \) -not -path './r11u108repro/*' -not -path './v11u108repro/*' | sort) > "$LIST"
one() {
  rel=$1; d=$(dirname "$rel"); f=$(basename "$rel"); key=$(echo "$rel" | sed 's#^\./##; s#/#__#g')
  w="$OUT/arms/$key"; mkdir -p "$w"
  (cd "$ROOT/$d" && timeout 120 "$ba" "$f" --single-unit --nobuiltin -o "$w/$ta.uhdm" </dev/null >/dev/null 2>&1); ra=$?
  (cd "$ROOT/$d" && timeout 120 "$bb" "$f" --single-unit --nobuiltin -o "$w/$tb.uhdm" </dev/null >/dev/null 2>&1); rb=$?
  if [ $ra != $rb ]; then v=RCDIFF
  elif [ -f "$w/$ta.uhdm" ] && [ -f "$w/$tb.uhdm" ]; then cmp -s "$w/$ta.uhdm" "$w/$tb.uhdm" && v=SAME || v=MOVED
  elif [ ! -f "$w/$ta.uhdm" ] && [ ! -f "$w/$tb.uhdm" ]; then v=NOOUT
  else v=OUTDIFF; fi
  [ $v = SAME ] && rm -f "$w/$ta.uhdm" "$w/$tb.uhdm"
  echo "$v $rel rc=$ra/$rb"
}
export -f one; export OUT ROOT ta ba tb bb
xargs -a "$LIST" -P "${JOBS:-3}" -I{} bash -c 'one "$@"' _ {} > "$OUT/result.txt"
echo "LISTED=$(wc -l < "$LIST") PROCESSED=$(wc -l < "$OUT/result.txt")"
awk '{print $1}' "$OUT/result.txt" | sort | uniq -c
grep -v '^SAME\|^NOOUT' "$OUT/result.txt" | sort
