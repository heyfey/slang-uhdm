#!/bin/bash
# gridv108.sh <grid-dir> <out-root> <tag>=<binary> [...]
# MODE=tf (default): surelog -parse -nobuiltin -nocache -sv / slang --single-unit --nobuiltin
# MODE=def:          surelog -parse -nocache -sv           / slang --single-unit
# Every arm = every dut.sv under <grid-dir> (subdirs included), list read on fd 3.
# Prints "arm tag lines heads rc=<ours> grc=<golden>"; asserts PROCESSED == LISTED.
GRID=${1:?grid}; OUT=${2:?out}; shift 2
MODE=${MODE:-tf}
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
if [ "$MODE" = tf ]; then SLF="-nobuiltin"; OF="--nobuiltin"; else SLF=""; OF=""; fi
mkdir -p "$OUT"
LIST=$(mktemp "$OUT/list.XXXX"); (cd "$GRID" && find . -name dut.sv | sort) > "$LIST"
N=0
while read -r rel <&3; do
  arm=$(dirname "${rel#./}"); src="$GRID/$arm"; w="$OUT/$arm"; mkdir -p "$w"
  if [ ! -f "$w/gold/ok" ]; then
    rm -rf "$w/gold"; mkdir -p "$w/gold"
    (cd "$src" && timeout 300 "$SL" -parse $SLF -nocache -sv dut.sv -mt 0 -mp 0 -o "$w/gold" </dev/null > "$w/gold/log" 2>&1); echo "$?" > "$w/gold/rc"
    g=$(ls "$w"/gold/slpp_*/*.uhdm 2>/dev/null | head -1); [ -n "$g" ] && cp "$g" "$w/gold.uhdm" && touch "$w/gold/ok"
  fi
  grc=$(cat "$w/gold/rc")
  for tb in "$@"; do
    tag=${tb%%=*}; bin=${tb#*=}
    rm -f "$w/$tag.uhdm"
    (cd "$src" && timeout 300 "$bin" dut.sv --single-unit $OF -o "$w/$tag.uhdm" </dev/null > "$w/$tag.log" 2>&1); rc=$?
    echo "$bin" > "$w/$tag.bin"
    if [ -f "$w/gold.uhdm" ] && [ -f "$w/$tag.uhdm" ]; then
      "$CMP" "$w/gold.uhdm" "$w/$tag.uhdm" > "$w/$tag.cmp" 2>&1
      echo "$arm $tag $(wc -l < "$w/$tag.cmp") $(grep -c '^LHS:' "$w/$tag.cmp"; true) rc=$rc grc=$grc"
    else
      echo "$arm $tag NA NA rc=$rc grc=$grc"
    fi
  done
  N=$((N+1))
done 3< "$LIST"
echo "PROCESSED=$N LISTED=$(wc -l < "$LIST")"
rm -f "$LIST"
