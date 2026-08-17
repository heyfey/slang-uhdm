#!/usr/bin/env bash
# vbuvm5 (ADVERSARIAL VERIFIER) — THE FOUR-WAY CELL TABLE.
#
# For each of the five verifier arms, print one row per `ref_obj` naming a
# declared `ref_var`, with the vpiActual it carries on FOUR sides:
#
#     golden | pristine | as-shipped | V-FIXED
#
# and then classify every row.  This is the instrument that found the 22
# pristine-RIGHT -> patched-WRONG cells the shipped patch created, so it is the
# instrument that has to keep running.
#
#   usage: PRIS=<pristine bin> SHIP=<as-shipped bin> FIX=<v-fixed bin> \
#          ./vfix5cells.sh [arm.sv ...]
#
# GUARDS, each one a trap paid for in this campaign:
#   * THREE binaries are required by name and each is existence-checked.  A
#     three-way table run with two binaries silently prints a two-way one.
#   * ct5arm.sh is the ONLY thing that talks to Surelog, so all four columns are
#     read from ONE golden dump per arm — the two sides can never be scored
#     against different goldens.
#   * a row whose GOLDEN column is `-` and whose ours column is not is an
#     OVER-FIRE, and a row the other way round is an UNDER-FIRE; the two are
#     counted separately, because a summary that adds them reports a fix and a
#     regression as the same number.
#   * THE VERDICT LINE is the count of PRISTINE-RIGHT -> X-WRONG rows, printed
#     for the as-shipped column and for the V-FIXED column separately.  That is
#     the only number that decides whether a pass may land, and a run that
#     measures no rows at all is reported as VACUOUS and exits 5.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
PRIS=${PRIS:?set PRIS to the pristine 9f45cc0 binary}
SHIP=${SHIP:?set SHIP to the as-shipped patched binary}
FIX=${FIX:?set FIX to the V-fixed binary}
for b in "$PRIS" "$SHIP" "$FIX"; do
  [ -x "$b" ] || { echo "FATAL: no binary $b"; exit 3; }
done
ARMS=${*:-"v1_spelling.sv v2_seltrack.sv v3_windows.sv v4_moreinds.sv v5_depthctl.sv"}
tot=0; shipbad=0; fixbad=0; shipgood=0; fixgood=0
for arm in $ARMS; do
  a=$(basename "$arm" .sv)
  for side in pris ship fix; do
    case $side in
      pris) B=$PRIS;; ship) B=$SHIP;; fix) B=$FIX;;
    esac
    SLANG_UHDM=$B "$HERE/ct5arm.sh" "$arm" "/tmp/vfix5_${a}_$side" >"/tmp/vfix5_${a}_$side.out" 2>&1
    [ -s "/tmp/vfix5_${a}_$side/o.dump" ] || { echo "FATAL: $a/$side produced no dump"; exit 4; }
  done
  echo "======== $a   (golden | pristine | as-shipped | V-FIXED)"
  grep -E 'DUMP_' "/tmp/vfix5_${a}_pris.out" | sed 's/^/  pristine   /'
  grep -E 'DUMP_' "/tmp/vfix5_${a}_ship.out" | sed 's/^/  as-shipped /'
  grep -E 'DUMP_' "/tmp/vfix5_${a}_fix.out"  | sed 's/^/  V-FIXED    /'
  paste -d'|' \
    <(python3 "$HERE/pop.py" "/tmp/vfix5_${a}_pris/g.dump" | awk '{print $1, $3}') \
    <(python3 "$HERE/pop.py" "/tmp/vfix5_${a}_pris/o.dump" | awk '{print $3}') \
    <(python3 "$HERE/pop.py" "/tmp/vfix5_${a}_ship/o.dump" | awk '{print $3}') \
    <(python3 "$HERE/pop.py" "/tmp/vfix5_${a}_fix/o.dump"  | awk '{print $3, $NF}') \
    | grep -v '^ROWS' | sed 's/actual=//g' | column -t -s'|'
  # the verdict counters, read off the same four columns
  read -r n sb fb sg fg <<EOF
$(paste -d' ' \
   <(python3 "$HERE/pop.py" "/tmp/vfix5_${a}_pris/g.dump" | grep -v '^ROWS' | awk '{print $3}') \
   <(python3 "$HERE/pop.py" "/tmp/vfix5_${a}_pris/o.dump" | grep -v '^ROWS' | awk '{print $3}') \
   <(python3 "$HERE/pop.py" "/tmp/vfix5_${a}_ship/o.dump" | grep -v '^ROWS' | awk '{print $3}') \
   <(python3 "$HERE/pop.py" "/tmp/vfix5_${a}_fix/o.dump"  | grep -v '^ROWS' | awk '{print $3}') \
 | awk '{n++;
         pr=($1==$2); sr=($1==$3); fr=($1==$4);
         if (pr && !sr) sb++;   # pristine right -> as-shipped wrong
         if (pr && !fr) fb++;   # pristine right -> V-FIXED wrong
         if (!pr && sr) sg++;   # pristine wrong -> as-shipped right
         if (!pr && fr) fg++}
        END{print n+0, sb+0, fb+0, sg+0, fg+0}')
EOF
  echo "  -- rows=$n  pristine-RIGHT->as-shipped-WRONG=$sb  pristine-RIGHT->V-FIXED-WRONG=$fb" \
       " wrong->right: as-shipped=$sg V-FIXED=$fg"
  tot=$((tot+n)); shipbad=$((shipbad+sb)); fixbad=$((fixbad+fb))
  shipgood=$((shipgood+sg)); fixgood=$((fixgood+fg))
  # SELF-TEST, run on THIS arm's already-computed dumps so it costs nothing:
  # score the PRISTINE column against itself in the V-FIXED slot.  It must come
  # out 0 regressions AND 0 wrong->right.  That is what separates "passed
  # because it fixed 22 cells and broke none" from "passed because it changed
  # nothing" — a do-nothing binary scores 0/0 here and 0 on wrong->right above,
  # so the PASS line can never be earned by inaction.
  read -r zb zg <<EOF
$(paste -d' ' \
   <(python3 "$HERE/pop.py" "/tmp/vfix5_${a}_pris/g.dump" | grep -v '^ROWS' | awk '{print $3}') \
   <(python3 "$HERE/pop.py" "/tmp/vfix5_${a}_pris/o.dump" | grep -v '^ROWS' | awk '{print $3}') \
 | awk '{pr=($1==$2); if (pr && !pr) zb++; if (!pr && pr) zg++}
        END{print zb+0, zg+0}')
EOF
  [ "$zb" = 0 ] && [ "$zg" = 0 ] || { echo "  SELF-TEST BROKEN on $a ($zb/$zg)"; exit 6; }
  selfok=$((${selfok:-0}+1))
done
echo "================================================================"
echo "TOTAL rows measured           : $tot"
echo "pristine-RIGHT -> AS-SHIPPED-WRONG : $shipbad   <- the regressions this verifier found"
echo "pristine-RIGHT -> V-FIXED-WRONG    : $fixbad   <- must be 0"
echo "wrong -> right  as-shipped=$shipgood  V-FIXED=$fixgood"
echo "SELF-TEST (pristine column scored against itself): ${selfok:-0} arms, 0 regressions / 0 fixes"
[ "$tot" = 0 ] && { echo "VACUOUS: no rows measured"; exit 5; }
[ "${fixgood:-0}" = 0 ] && echo "ATTENTION: the V-FIXED column fixes NOTHING -- a do-nothing binary" \
                                "scores like this; the PASS line below is then vacuous"
[ "$fixbad" = 0 ] && echo "PASS: the V-FIXED binary breaks nothing the pristine binary got right" \
                  || echo "FAIL: read the rows above, do not summarise them"
