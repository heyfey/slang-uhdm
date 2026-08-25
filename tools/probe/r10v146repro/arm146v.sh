#!/usr/bin/env bash
# v146 VERIFIER arm driver. MEASUREMENT ONLY; official uhdm-cmp is the judge.
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
set -u
SRC=$(readlink -f "${1:?arms dir}"); OUT=$(readlink -f "${2:?outdir}"); mkdir -p "$OUT"
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
echo "BINARIES pris=$PRIS pat=$PATCHED surelog=$SURELOG cmp=$CMP"
find "$SRC" -name '*.sv' | sort > "$OUT/LISTED"
L=$(wc -l < "$OUT/LISTED"); P=0
printf "%-34s %-22s %-22s %s\n" ARM "DEF pris/pat(heads)" "ELAB pris/pat(heads)" VERDICT
while read -r f <&3; do
  rel=${f#$SRC/}; key=$(echo "$rel" | tr '/' '_'); key=${key%.sv}
  W="$OUT/$key"; mkdir -p "$W"; cp "$f" "$W/"; b=$(basename "$f")
  ( cd "$W" && "$SURELOG" -parse -sv "$b" -mt 0 -mp 0 -o slD ) </dev/null >"$W/slD.log" 2>&1; gd=$?
  ( cd "$W" && "$SURELOG" -parse -elabuhdm -sv "$b" -mt 0 -mp 0 -o slE ) </dev/null >"$W/slE.log" 2>&1; ge=$?
  ( cd "$W" && "$PRIS"    "$b" --single-unit -o pD.uhdm ) </dev/null >"$W/pD.log" 2>&1; pd=$?
  ( cd "$W" && "$PATCHED" "$b" --single-unit -o qD.uhdm ) </dev/null >"$W/qD.log" 2>&1; qd=$?
  ( cd "$W" && "$PRIS"    "$b" --single-unit --elabuhdm -o pE.uhdm ) </dev/null >"$W/pE.log" 2>&1; pe=$?
  ( cd "$W" && "$PATCHED" "$b" --single-unit --elabuhdm -o qE.uhdm ) </dev/null >"$W/qE.log" 2>&1; qe=$?
  GD="$W/slD/slpp_all/surelog.uhdm"; [ -f "$GD" ] || GD="$W/slD/surelog.uhdm"
  GE="$W/slE/slpp_all/surelog.uhdm"; [ -f "$GE" ] || GE="$W/slE/surelog.uhdm"
  dl=-; dq=-; el=-; eq=-; dlh=-; dqh=-; elh=-; eqh=-
  if [ -f "$GD" ] && [ -f "$W/pD.uhdm" ]; then "$CMP" "$GD" "$W/pD.uhdm" >"$W/pD.cmp" 2>&1; dl=$(wc -l <"$W/pD.cmp"); dlh=$(grep -c '^LHS:' "$W/pD.cmp"; true); fi
  if [ -f "$GD" ] && [ -f "$W/qD.uhdm" ]; then "$CMP" "$GD" "$W/qD.uhdm" >"$W/qD.cmp" 2>&1; dq=$(wc -l <"$W/qD.cmp"); dqh=$(grep -c '^LHS:' "$W/qD.cmp"; true); fi
  if [ -f "$GE" ] && [ -f "$W/pE.uhdm" ]; then "$CMP" "$GE" "$W/pE.uhdm" >"$W/pE.cmp" 2>&1; el=$(wc -l <"$W/pE.cmp"); elh=$(grep -c '^LHS:' "$W/pE.cmp"; true); fi
  if [ -f "$GE" ] && [ -f "$W/qE.uhdm" ]; then "$CMP" "$GE" "$W/qE.uhdm" >"$W/qE.cmp" 2>&1; eq=$(wc -l <"$W/qE.cmp"); eqh=$(grep -c '^LHS:' "$W/qE.cmp"; true); fi
  v=OK
  [ "$pd" != "$qd" ] && v="RC-DIFF-DEF($pd/$qd)"
  [ "$pe" != "$qe" ] && v="$v RC-DIFF-ELAB($pe/$qe)"
  [ "$dl" = 0 ] && [ "$dq" != 0 ] && v="$v REGRESS-DEF"
  [ "$el" = 0 ] && [ "$eq" != 0 ] && v="$v REGRESS-ELAB"
  [ "$dl" != "$dq" ] && v="$v DEFMOVED"
  [ "$el" != "$eq" ] && v="$v ELABMOVED"
  cmp -s "$W/pD.uhdm" "$W/qD.uhdm" || v="$v BYTES-DEF"
  cmp -s "$W/pE.uhdm" "$W/qE.uhdm" || v="$v BYTES-ELAB"
  printf "%-34s %-22s %-22s %s\n" "$rel" "$dl($dlh)/$dq($dqh)" "$el($elh)/$eq($eqh)" "$v"
  P=$((P+1))
done 3< "$OUT/LISTED"
echo "LISTED=$L PROCESSED=$P"
[ "$L" = "$P" ] && [ "$L" -gt 0 ] && echo "ARM-DRIVER OK" || echo "ARM-DRIVER FAIL"
