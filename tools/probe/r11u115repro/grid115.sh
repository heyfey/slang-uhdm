#!/bin/bash
# grid115.sh <grid-dir> <out-root> <bin-tag>=<binary> [...]
# (r11u113repro/grid113.sh, unchanged logic.)  Per arm (every <grid-dir>/**/dut.sv,
# subdirs included) and per form in ${FORMS:-u2r elab}:
#   u2r : golden = pinned Surelog -parse -nobuiltin -nocache -sv dut.sv ; ours = --single-unit --nobuiltin
#   elab: golden = pinned Surelog -parse -elabuhdm -nobuiltin dut.sv     ; ours = --elabuhdm --single-unit --nobuiltin
# Records rc for every run (an arm whose golden compile fails is reported, never scored),
# runs uhdm-cmp (LHS golden) and prints "arm/form tag lines heads rc".
GRID=${1:?grid}; OUT=${2:?out}; shift 2
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
FORMS=${FORMS:-u2r elab}
mkdir -p "$OUT"
LIST=$(mktemp "$OUT/list.XXXX"); (cd "$GRID" && find . -name dut.sv | sort) > "$LIST"
N=0
while read -r rel <&3; do
  arm=$(dirname "${rel#./}"); src="$GRID/$arm"
  for form in $FORMS; do
    w="$OUT/$arm/$form"; mkdir -p "$w"
    if [ "$form" = elab ]; then sla=(-parse -elabuhdm -nobuiltin dut.sv); oa=(--elabuhdm dut.sv --single-unit --nobuiltin)
    else sla=(-parse -nobuiltin -nocache -sv dut.sv); oa=(dut.sv --single-unit --nobuiltin); fi
    if [ ! -f "$w/gold/ok" ]; then
      rm -rf "$w/gold"; mkdir -p "$w/gold"
      (cd "$src" && timeout 300 "$SL" "${sla[@]}" -mt 0 -mp 0 -o "$w/gold" </dev/null > "$w/gold/log" 2>&1); echo "rc=$?" > "$w/gold/rc"
      g=$(ls "$w"/gold/slpp_*/*.uhdm 2>/dev/null | head -1); [ -n "$g" ] && grep -qx 'rc=0' "$w/gold/rc" && cp "$g" "$w/gold.uhdm" && touch "$w/gold/ok"
    fi
    for tb in "$@"; do
      tag=${tb%%=*}; bin=${tb#*=}
      rm -f "$w/$tag.uhdm"
      (cd "$src" && timeout 300 "$bin" "${oa[@]}" -o "$w/$tag.uhdm" </dev/null > "$w/$tag.log" 2>&1); rc=$?
      if [ -f "$w/gold.uhdm" ] && [ -f "$w/$tag.uhdm" ]; then
        "$CMP" "$w/gold.uhdm" "$w/$tag.uhdm" > "$w/$tag.cmp" 2>&1
        echo "$arm/$form $tag $(wc -l < "$w/$tag.cmp") $(grep -c '^LHS:' "$w/$tag.cmp"; true) rc=$rc"
      else
        echo "$arm/$form $tag NA NA rc=$rc gold=$(cat "$w/gold/rc")"
      fi
    done
  done
  N=$((N+1))
done 3< "$LIST"
echo "PROCESSED=$N LISTED=$(wc -l < "$LIST")"
rm -f "$LIST"
