#!/bin/bash
# (copied from r11u107 grid107.sh unchanged; the verifier runs it with its own out-root)
# grid107.sh <grid-dir> <out-root> <bin-tag>=<binary> [...]
# Per arm (every <grid-dir>/<arm>/dut.sv, subdirs included): golden via the
# pinned Surelog (testflags form: -parse -nobuiltin -nocache -sv), ours via each
# named binary (--single-unit --nobuiltin).  Records rc for every run, runs
# uhdm-cmp (LHS golden) and prints "arm tag lines heads rc".
GRID=${1:?grid}; OUT=${2:?out}; shift 2
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
mkdir -p "$OUT"
LIST=$(mktemp "$OUT/list.XXXX"); (cd "$GRID" && find . -name dut.sv | sort) > "$LIST"
N=0
while read -r rel <&3; do
  arm=$(dirname "${rel#./}"); src="$GRID/$arm"; w="$OUT/$arm"; mkdir -p "$w"
  if [ ! -f "$w/gold/ok" ]; then
    rm -rf "$w/gold"; mkdir -p "$w/gold"
    (cd "$src" && timeout 300 "$SL" -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$w/gold" </dev/null > "$w/gold/log" 2>&1); echo "rc=$?" > "$w/gold/rc"
    g=$(ls "$w"/gold/slpp_*/*.uhdm 2>/dev/null | head -1); [ -n "$g" ] && cp "$g" "$w/gold.uhdm" && touch "$w/gold/ok"
  fi
  for tb in "$@"; do
    tag=${tb%%=*}; bin=${tb#*=}
    rm -f "$w/$tag.uhdm"
    (cd "$src" && timeout 300 "$bin" dut.sv --single-unit --nobuiltin -o "$w/$tag.uhdm" </dev/null > "$w/$tag.log" 2>&1); rc=$?
    if [ -f "$w/gold.uhdm" ] && [ -f "$w/$tag.uhdm" ]; then
      "$CMP" "$w/gold.uhdm" "$w/$tag.uhdm" > "$w/$tag.cmp" 2>&1
      echo "$arm $tag $(wc -l < "$w/$tag.cmp") $(grep -c '^LHS:' "$w/$tag.cmp"; true) rc=$rc"
    else
      echo "$arm $tag NA NA rc=$rc gold=$(cat "$w/gold/rc")"
    fi
  done
  N=$((N+1))
done 3< "$LIST"
echo "PROCESSED=$N LISTED=$(wc -l < "$LIST")"
rm -f "$LIST"
