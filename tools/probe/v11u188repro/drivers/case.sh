#!/bin/bash
# v11u188: case.sh <case dir>: judge one case (dut.sv, or dut.v) with every binary of $BINS (default P=pris L=law
# V=v2 under $V188_BIN) against the pinned Surelog golden (check_probe.py's flags; cached per dir+text md5 in
# ${V188_GOLD:-/tmp/v11u188_gold}).  Prints "<cell> <name>:rc=<rc>:cmp<lines>:<strict verdict>(<objects>)".
. "$(dirname "$0")/env.sh" || exit 9
D=$(cd "$1" && pwd); v188_fenced "$D" && { echo "case.sh: fenced path refused" >&2; exit 9; }
TOP=dut.sv; [ ! -f "$D/dut.sv" ] && [ -f "$D/dut.v" ] && TOP=dut.v
K=$( (echo "$D"; cat "$D"/*.sv "$D"/*.svh "$D"/*.v 2>/dev/null) | md5sum | cut -c1-16); G=${V188_GOLD:-/tmp/v11u188_gold}/$K
if [ ! -s "$G/golden.uhdm" ]; then rm -rf "$G"; mkdir -p "$G/w"; ( cd "$D" && timeout 300 "$SURELOG" -parse -nobuiltin -nocache -sv $TOP -mt 0 -mp 0 -o "$G/w" > "$G/sl.log" 2>&1 )
  u=$(find "$G/w" -name '*.uhdm' | head -1); [ -n "$u" ] && cp "$u" "$G/golden.uhdm"; rm -rf "$G/w"; fi
[ -s "$G/golden.uhdm" ] || { echo "$(basename $D) SURELOG_FAIL"; exit 1; }
O=${V188_RUN:-/tmp/v11u188_run}/$(echo "$D" | md5sum | cut -c1-12); mkdir -p $O
line="$(basename $D)"
for nb in ${BINS:-P=$V188_BIN/pris.bin L=$V188_BIN/law.bin V=$V188_BIN/v2.bin}; do
  n=${nb%%=*}; b=${nb#*=}; rm -f $O/$n.uhdm
  ( cd "$D" && "$b" $TOP --single-unit --nobuiltin -o "$O/$n.uhdm" > "$O/$n.log" 2>&1; echo "rc=$?" >> "$O/$n.log" )
  rc=$(tail -1 $O/$n.log)
  if [ ! -s $O/$n.uhdm ]; then line="$line $n:NOUHDM($rc)"; continue; fi
  "$UHDM_CMP" "$G/golden.uhdm" "$O/$n.uhdm" > "$O/$n.cmp" 2>&1
  "$SCMP" --max 20 --dump-a "$O/g.rec" --dump-b "$O/$n.rec" "$G/golden.uhdm" "$O/$n.uhdm" > "$O/$n.strict" 2>&1
  "$UHDM_DUMP" "$O/$n.uhdm" 2>/dev/null | sed "s#$O/##g" > $O/$n.dump
  st=$(grep -m1 -oE "^(STRICT_EQUAL|STRICT_NOTEQUAL|NOT_EQUAL)[^,]*" $O/$n.strict | head -c 60 | tr " " "_")$(grep -m1 -oE "objects_differing=[0-9]+" $O/$n.strict | sed "s/objects_differing=/(/;s/$/)/")
  line="$line $n:$rc:cmp$(wc -l < $O/$n.cmp):$st"
done
"$UHDM_DUMP" "$G/golden.uhdm" 2>/dev/null | sed "s#$G/##g" > $O/g.dump
echo "$line"
