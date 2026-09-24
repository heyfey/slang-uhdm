#!/usr/bin/env bash
# r11u119 grid driver: per arm (every dut.sv under <root>, subdirs included)
#   G  golden  = the pinned Surelog v1.87 ($SURELOG) with the probe flags
#   O  ours    = $SLANG_UHDM dut.sv --single-unit --nobuiltin
# scored PER CELL on the location rows (locdump: type(name) file l.c-el.ec
# <- parents, order-blind multiset): SPANDIFF = number of rows on one side
# only; CMP = uhdm-cmp line count (must stay 0); rc of both producers.
# With DS=1 the downstream verdict (downstream_uhdm2rtlil.one, uhdm2rtlil's
# own Surelog + -DSYNTHESIS vs the translated slang lane) is appended.
#   grid119.sh <root> <outdir>      (SLANG_UHDM, SURELOG, UHDM_CMP exported)
set -u
root=$(realpath "$1"); out=$2; mkdir -p "$out"
LD=${LOCDUMP:-/tmp/r11u119_scr/locdump}
REPO=${REPO:-$(cd "$(dirname "$0")/../../.." && pwd)}
exec 3< <(cd "$root" && find . -name dut.sv | sort)
n=0
while read -r rel <&3; do
  d=$(dirname "$rel"); key=${d#./}; key=${key//\//__}
  w=$out/$key; rm -rf "$w"; mkdir -p "$w/g"
  ( cd "$root/$d" && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -o "$w/g" </dev/null >"$w/g.log" 2>&1 ); grc=$?
  g=$(find "$w/g" -name '*.uhdm' | head -1)
  ( cd "$root/$d" && "$SLANG_UHDM" dut.sv --single-unit --nobuiltin -o "$w/o.uhdm" </dev/null >"$w/o.log" 2>&1 ); orc=$?
  sd=NA; cm=NA
  if [ -n "$g" ] && [ -s "$w/o.uhdm" ]; then
    "$LD" "$g" > "$w/g.loc"; "$LD" "$w/o.uhdm" > "$w/o.loc"
    sd=$(diff "$w/g.loc" "$w/o.loc" | grep -c '^[<>]'); true
    cm=$("$UHDM_CMP" "$g" "$w/o.uhdm" 2>&1 | wc -l)
  fi
  ds=""
  if [ "${DS:-0}" = 1 ]; then
    ds=$(cd "$REPO" && python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('$key', '$root/$d', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$w/ds', 300); print(r['verdict'], r['differs'].replace(' ','+') or '-')" 2>&1 | tail -1)
  fi
  echo "$key grc=$grc orc=$orc SPANDIFF=$sd CMP=$cm $ds"
  n=$((n+1))
done | tee "$out/score.txt"
echo "PROCESSED=$(wc -l < "$out/score.txt") LISTED=$(cd "$root" && find . -name dut.sv | wc -l)"
