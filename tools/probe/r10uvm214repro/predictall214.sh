#!/usr/bin/env bash
# r10uvm214 — THE CORPUS-WIDE A-PRIORI PREDICTION, from PRISTINE databases
# alone.  MEASUREMENT ONLY; the official uhdm-cmp is the judge.
#
# Walks every row of a `verify_golden.py` workdir, reads OUR database only, and
# counts the cells § pkgCloneBodyBindsOwnListingRhs214 will re-bind (the fire
# set is defined in predict214.py's header, and the PREDICTED post-patch payload
# of every cell is read out of our own def listing).  Every row with FIRE>0 is a
# PREDICTED BYTE MOVER, named here BEFORE the patched sweep is built.  For each
# such row the row's own golden is then loaded and the verdict printed
# (TO-GOLDEN / AWAY / MOVED-WRONG / UNSEEN), so a mover that would leave golden
# is caught before a line of it is claimed.
#
# usage: TS=<ct214bind> PRED=<predict214.py> ./predictall214.sh <workdir> <out> [scratchdir]
#
# GUARDS: a row whose golden is missing is printed `golden=NO` and COUNTED, not
# skipped; the golden path is read out of the row's own cmds.txt; the four
# slang-fenced test names are never spelled here — a fenced row is identified
# only by the fence list `canaudit.sh` carries, which `scrub214.sh` reads.
set -u
WD=${1:?workdir}; OUT=${2:?out}
SCR=${3:-$OUT.scratch}
TS=${TS:?path to ct214bind}
PRED=${PRED:?path to predict214.py}
mkdir -p "$SCR" || exit 1
: > "$OUT"
rows=0; fired=0; nog=0
for mode in default testflags; do
  [ -d "$WD/$mode" ] || continue
  for d in "$WD/$mode"/*/; do
    O=$d/slang.uhdm
    [ -f "$O" ] || continue
    rows=$((rows+1))
    n=$(basename "$d"); n=${n%-*}
    "$TS" --keycount "$O" . > "$SCR/o.kc" 2>/dev/null
    "$TS" --parhs "$O" > "$SCR/o.pa" 2>/dev/null
    # THE FIRE COUNT, from our database alone: a def-listing class-method clone
    # body reference whose actual lives in the SAME package's elaborated
    # listing.
    f=$(awk -F'\t' '
      match($4, /^package\[ALLPKG:[^]]+\]<(function|task):[^<]*::/) {
        p=$4; sub(/^package\[ALLPKG:/,"",p); sub(/\].*/,"",p);
        if (index($3, "[package[TOPPKG:" p "]]") > 0) s+=$5
      } END{print s+0}' "$SCR/o.kc")
    [ "$f" -eq 0 ] && continue
    fired=$((fired+1))
    G=""
    [ -f "$d/cmds.txt" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ]; then
      echo "FIRE $n $mode FIRE=$f golden=NO" >> "$OUT"
      nog=$((nog+1)); continue
    fi
    "$TS" --keycount "$G" . > "$SCR/g.kc" 2>/dev/null
    v=$(python3 "$PRED" "$SCR/g.kc" "$SCR/o.kc" "$SCR/o.pa" | tail -1)
    echo "FIRE $n $mode $v" >> "$OUT"
  done
done
echo "-- rows scanned=$rows  rows with FIRE>0 =$fired  golden missing=$nog" >> "$OUT"
tail -1 "$OUT"
