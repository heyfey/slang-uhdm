#!/bin/bash
# v132 verifier arm runner (measurement only).
set -u
ARM=${1:?arm .sv}
PRI=/tmp/v132_bin/pris.bin
PAT=/tmp/v132_bin/pat.bin
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/.local/bin/uhdm-dump
SC=/tmp/v132_scratch/vscore132.py
WD=/tmp/v132_scratch/awd/$(basename "$ARM" .sv)
rm -rf "$WD"; mkdir -p "$WD" || exit 9
cp "$ARM" "$WD"/ || exit 9
[ -f "$(dirname "$ARM")/v_defs.svh" ] && cp "$(dirname "$ARM")/v_defs.svh" "$WD"/
leaf=$(basename "$ARM")
echo "=== ARM $leaf   PRI $(md5sum $PRI|cut -c1-12) PAT $(md5sum $PAT|cut -c1-12)"
for m in def elab; do
  fl=""; [ $m = elab ] && fl="-elabuhdm"
  ( cd "$WD" && "$SL" -parse -nonote -noinfo -nobuiltin $fl -d uhdm "$leaf" > sl_$m.log 2>&1 </dev/null ); slrc=$?
  g=$WD/slpp_all/surelog.uhdm
  if [ -f "$g" ]; then cp "$g" "$WD/gold_$m.uhdm"; else echo "  $m: NO GOLDEN (surelog rc=$slrc): $(grep -m3 -E '\[(ERR|SYNT)' $WD/sl_$m.log | tr '\n' ' ')"; fi
  ( cd "$WD" && "$PRI" $fl "$leaf" -o pris_$m.uhdm > pris_$m.log 2>&1 </dev/null ); prc=$?
  ( cd "$WD" && "$PAT" $fl "$leaf" -o pat_$m.uhdm  > pat_$m.log  2>&1 </dev/null ); qrc=$?
  for f in gold pris pat; do
    [ -f "$WD/${f}_$m.uhdm" ] && "$DUMP" "$WD/${f}_$m.uhdm" 2>/dev/null </dev/null | sed 1d > "$WD/${f}_$m.dump"
  done
  echo "  $m  slrc=$slrc pris rc=$prc pat rc=$qrc"
  if [ -f "$WD/pris_$m.dump" ] && [ -f "$WD/pat_$m.dump" ]; then
    d=$(diff "$WD/pris_$m.dump" "$WD/pat_$m.dump" | grep -cE '^[<>]'; true)
    echo "    PRIS-vs-PAT dump lines differing: $d"
  fi
  if [ -f "$WD/gold_$m.dump" ] && [ -f "$WD/pat_$m.dump" ]; then
    echo "    PRIS $(python3 "$SC" -c "$WD/gold_$m.dump" "$WD/pris_$m.dump" | head -1)"
    echo "    PAT  $(python3 "$SC" -c "$WD/gold_$m.dump" "$WD/pat_$m.dump"  | head -1)"
    python3 "$SC" -c "$WD/gold_$m.dump" "$WD/pris_$m.dump" > "$WD/sc_pris_$m.txt"
    python3 "$SC" -c "$WD/gold_$m.dump" "$WD/pat_$m.dump"  > "$WD/sc_pat_$m.txt"
  fi
  rm -rf "$WD/slpp_all" "$WD/slpp_unit"
done
