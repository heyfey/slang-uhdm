#!/usr/bin/env bash
# r10v126 (VERIFIER) — A-PRIORI mover prediction, read ONLY from the PRISTINE
# databases and their own goldens (never from a patched database).  A LAW cell
# is a fixed-size unpacked-array element typespec where golden's class is one
# of the keyword classes the pass now mints and ours is not, with NO name on
# either side (a NAMED golden typespec is residue 1, a different mechanism).
#   usage: predv126.sh <workdir-with-slang.uhdm-and-cmds.txt>
set -u
CEN=${CEN:-/tmp/v126_cenv}
WD=${1:?workdir}
scanned=0; movers=0; nogold=0
for d in "$WD"/*/*/; do
  [ -f "$d/slang.uhdm" ] || continue
  scanned=$((scanned+1))
  g=$(grep -oE '/home/heyfey/\.cache/slang-uhdm-goldens/[0-9a-f]+' "$d/cmds.txt" 2>/dev/null | head -1)
  G=""; [ -n "$g" ] && [ -f "$g/golden.uhdm" ] && G="$g/golden.uhdm"
  if [ -z "$G" ]; then
    G=$(ls "$d"/*.uhdm 2>/dev/null | grep -v slang.uhdm | head -1)
  fi
  [ -n "$G" ] || { nogold=$((nogold+1)); continue; }
  "$CEN" "$G" 2>/dev/null | awk -F'\t' '$1=="CELL"{print $2"\t"$3"\t"$5}' | sort > /tmp/v126_pg.$$
  "$CEN" "$d/slang.uhdm" 2>/dev/null | awk -F'\t' '$1=="CELL"{print $2"\t"$3"\t"$5}' | sort > /tmp/v126_po.$$
  n=$(join -t$'\t' -j 1 -o 0,1.2,2.2 \
        <(awk -F'\t' '{print $1"\x01"$2"\t"$3}' /tmp/v126_pg.$$) \
        <(awk -F'\t' '{print $1"\x01"$2"\t"$3}' /tmp/v126_po.$$) 2>/dev/null |
      awk -F'\t' '{split($2,a,"|"); split($3,b,"|");
        if (a[2]=="" && b[2]=="" && a[1]!=b[1] &&
            (a[1]=="string_typespec"||a[1]=="real_typespec"||a[1]=="short_real_typespec"||
             a[1]=="chandle_typespec"||a[1]=="event_typespec"||a[1]=="byte_typespec"||
             a[1]=="short_int_typespec"||a[1]=="long_int_typespec"||a[1]=="integer_typespec"||
             a[1]=="time_typespec") &&
            (b[1]=="int_typespec"||b[1]=="logic_typespec"||b[1]=="bit_typespec")) print}' |
      grep -c . || true)
  if [ "${n:-0}" -gt 0 ]; then movers=$((movers+1)); echo "PREDICT law=$n  ${d#$WD/}"; fi
done
rm -f /tmp/v126_pg.$$ /tmp/v126_po.$$
echo "SCANNED=$scanned PREDICTED_MOVERS=$movers NO_GOLDEN=$nogold"
