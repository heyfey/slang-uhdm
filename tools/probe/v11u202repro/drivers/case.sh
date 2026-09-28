#!/bin/bash
# v11u202: judge one case dir (dut.sv) with pris.bin and law.bin as check_probe does. Golden cached per text md5.
# Outputs go to $OUTDIR (default /tmp/v11u202_run/<hash>): {pris,law,v2}.uhdm, .log, .dump, strict record dumps.
# usage: case.sh <case dir>   env: BINS (default "pris law"; binaries $VB/<b>.bin), LAST (the binary compared with pris for MOVED), EXTRA (env for non-pris runs)
set -u
source "$(dirname "$0")/env.sh" || exit 3
D=$(cd "$1" && pwd)
for f in $FENCED; do grep -qw "$f" <<< "$D" && { echo "fenced path refused" >&2; exit 3; }; done
K=$(cd "$D" && find . -type f ! -name LAW ! -path './.v/*' | sort | xargs md5sum | md5sum | cut -c1-16); G=/tmp/v11u202_gold/$K
if [ ! -s "$G/golden.uhdm" ]; then mkdir -p "$G/w"; ( cd "$D" && "$SURELOG" -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$G/w" > "$G/sl.log" 2>&1 )
  u=$(find "$G/w" -name '*.uhdm' | head -1); [ -n "$u" ] && cp "$u" "$G/golden.uhdm"; rm -rf "$G/w"
  [ -s "$G/golden.uhdm" ] && $UHDM_DUMP "$G/golden.uhdm" 2>/dev/null > $G/g.dump; fi
[ -s "$G/golden.uhdm" ] || { echo "$1 SURELOG_FAIL"; exit 1; }
O=${OUTDIR:-/tmp/v11u202_run/$(echo "$D" | md5sum | cut -c1-12)}; mkdir -p $O; line="$(basename $(dirname $D))/$(basename $D)"
for b in ${BINS:-pris law}; do
  rm -f $O/$b.uhdm
  if [ $b != pris ]; then E="${EXTRA:-}"; else E=""; fi
  ( cd "$D" && env $E $VB/$b.bin dut.sv --single-unit --nobuiltin -o "$O/$b.uhdm" > "$O/$b.log" 2>&1; echo "rc=$?" >> "$O/$b.log" )
  rc=$(tail -1 $O/$b.log)
  if [ ! -s $O/$b.uhdm ]; then line="$line | $b $rc NODB"; continue; fi
  n=$($UHDM_CMP "$G/golden.uhdm" "$O/$b.uhdm" 2>&1 | grep -c .)
  st=$($SCMP --max 20 --dump-a $O/$b.a.rec --dump-b $O/$b.b.rec "$G/golden.uhdm" "$O/$b.uhdm" 2>&1 | grep -m1 -oE '^(STRICT_EQUAL|STRICT_NOTEQUAL.*|NOT_EQUAL.*|CMP.*)' | cut -c1-60)
  $UHDM_DUMP $O/$b.uhdm 2>/dev/null | sed "s#$O/##" > $O/$b.dump
  line="$line | $b $rc cmp=$n $st"
done
cmp -s $O/pris.uhdm $O/${LAST:-law}.uhdm && line="$line | SAMEBYTES" || line="$line | MOVED"
echo "$line"
