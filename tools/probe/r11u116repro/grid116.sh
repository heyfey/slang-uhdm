#!/bin/bash
# grid116.sh <grid-dir> <out-root> <bin-tag>=<binary> [...]  (grid114.sh, parallel -P3)
# Per arm (every <grid-dir>/**/dut.sv): golden via the pinned Surelog (testflags
# form: -parse -nobuiltin -nocache -sv), ours via each named binary
# (--single-unit --nobuiltin).  Records rc for every run, runs uhdm-cmp (LHS
# golden) and prints "arm tag lines heads rc".  Golden is built once per arm.
GRID=$(realpath "${1:?grid}"); OUT=${2:?out}; shift 2
mkdir -p "$OUT"; OUT=$(realpath "$OUT")
export GRID OUT SL=/home/heyfey/git-repos/Surelog/build/bin/surelog CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
export TBS="$*"
one() {
  rel=$1; arm=$(dirname "${rel#./}"); src="$GRID/$arm"; w="$OUT/$arm"; mkdir -p "$w"
  if [ ! -f "$w/gold/ok" ]; then
    rm -rf "$w/gold"; mkdir -p "$w/gold"
    (cd "$src" && timeout 300 "$SL" -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$w/gold" </dev/null > "$w/gold/log" 2>&1); echo "rc=$?" > "$w/gold/rc"
    g=$(ls "$w"/gold/slpp_*/*.uhdm 2>/dev/null | head -1); [ -n "$g" ] && cp "$g" "$w/gold.uhdm" && touch "$w/gold/ok"
  fi
  for tb in $TBS; do
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
}
export -f one
LIST=$(mktemp "$OUT/list.XXXX"); (cd "$GRID" && find . -name dut.sv | sort) > "$LIST"
xargs -P 3 -I{} bash -c 'one "$@"' _ {} < "$LIST" | sort
echo "LISTED=$(wc -l < "$LIST")"
rm -f "$LIST"
