#!/usr/bin/env bash
# r10uvm215 — THE CORPUS-WIDE A-PRIORI PREDICTION, from PRISTINE databases
# alone.  MEASUREMENT ONLY; the official uhdm-cmp is the judge.
#
# § modportNeedsSimplePort215 deletes exactly the `modport` objects we mint with
# an EMPTY io_decl list (and re-lists a port view only when its connected
# modport is one of those), so the byte-mover set is decidable from OUR PRISTINE
# database alone: a row moves iff `ct215pred` finds emptyModports>0 in it.  This
# driver walks a whole `verify_golden.py` workdir and names every predicted
# mover BEFORE the patched sweep exists.
#
# For each predicted mover the row's OWN golden is then loaded and scored with
# the modport census, so the DIRECTION is settled a priori too:
#   TO-GOLDEN   golden holds no modport of that name    (the law is right here)
#   AWAY        golden DOES hold it                     (the law would be wrong)
# A row whose golden is missing is printed `golden=NO` and COUNTED, never
# skipped (uhdm-cmp exits 0 on a missing input — RESUME §9).
#
# usage: PRED=<ct215pred> CEN=<ct215mpcen> ./predictall215.sh <workdir> <out> [scratch]
#
# GUARDS: the golden path is read out of the row's own cmds.txt; the four
# slang-fenced test names are never spelled here — `scrub215.sh` redacts them
# from the artifact afterwards, reading the list out of `canaudit.sh`.
set -u
WD=${1:?workdir}; OUT=${2:?out}
SCR=${3:-$OUT.scratch}
PRED=${PRED:?path to ct215pred}
CEN=${CEN:?path to ct215mpcen}
mkdir -p "$SCR" || exit 1
: > "$OUT"
rows=0; fired=0; nog=0; away=0
for mode in default testflags; do
  [ -d "$WD/$mode" ] || continue
  for d in "$WD/$mode"/*/; do
    O=$d/slang.uhdm
    [ -f "$O" ] || continue
    rows=$((rows+1))
    n=$(basename "$d"); n=${n%-*}
    line=$("$PRED" "$O" 2>/dev/null)
    case "$line" in MOVER*) : ;; *) continue ;; esac
    fired=$((fired+1))
    e=${line#MOVER emptyModports=}; e=${e%% *}
    G=""
    [ -f "$d/cmds.txt" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ]; then
      echo "FIRE $n $mode emptyModports=$e golden=NO" >> "$OUT"
      nog=$((nog+1)); continue
    fi
    "$CEN" "$O" > "$SCR/o.cen" 2>/dev/null
    "$CEN" "$G" > "$SCR/g.cen" 2>/dev/null
    # Every EMPTY modport of ours, checked against golden's census for a
    # modport of the SAME name on the SAME interface view.  A hit is an AWAY
    # cell and the law would be wrong on this row.
    a=$(awk -F'|' 'NR==FNR{ if ($1=="MP") g[$2"|"$3"|"$4"|"$5]=1; next }
                   $1=="MP" && $6=="<null>" { if (($2"|"$3"|"$4"|"$5) in g) c++ }
                   END{print c+0}' "$SCR/g.cen" "$SCR/o.cen")
    t=$((e - a))
    [ "$a" -gt 0 ] && away=$((away+1))
    echo "FIRE $n $mode emptyModports=$e TO-GOLDEN=$t AWAY=$a" >> "$OUT"
  done
done
echo "-- rows scanned=$rows  PREDICTED MOVERS=$fired  golden missing=$nog  rows with AWAY>0 =$away" >> "$OUT"
tail -1 "$OUT"
