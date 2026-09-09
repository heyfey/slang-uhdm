#!/usr/bin/env bash
# r10uvm227 — RE-SCORE EVERY MOVED BOUNDARY ARM AGAINST A FRESH SURELOG.
# MEASUREMENT ONLY; the official `uhdm-cmp` is the judge here too.
#
# `bound227.sh` proves WHICH probe arms moved; it cannot say whether they moved
# TOWARD golden, and an md5 difference is not even proof of a real mover: some
# arms are NONDETERMINISTIC on ONE binary (a4_pkg_holder of this pass's own
# grid produced three different md5s from three runs of the PRISTINE binary —
# RESUME §9's macro-buffer SourceLocation ordering).  So every moved arm gets
# THREE readings:
#   1. a DETERMINISM control — the PRISTINE binary run twice; if its own two
#      databases differ, the md5 move proves nothing and the arm is reported
#      NONDET;
#   2. the OFFICIAL `uhdm-cmp` (LHS golden, RHS ours) on the pristine and on
#      the patched database — cmp lines and `^LHS:` head count;
#   3. an ORDER-BLIND dump distance to golden (sorted dumps, workdir paths
#      normalised), as the secondary axis.
# An arm whose compile FAILS on either side is reported and teaches error
# recovery, not golden (uvm215's lesson).
#
#   usage: bash bscore227.sh <BOUNDARY.txt> <boundary scratch> <out> <pristine bin>
set -u
B=${1:?BOUNDARY.txt}; SCR=${2:?scratch}; OUT=${3:?out}; A=${4:?pristine binary}
SL=${SL:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
[ -x "$CMP" ] || { echo "FATAL: no uhdm-cmp at $CMP"; exit 3; }
: > "$OUT"
n=0; tg=0; aw=0; sm=0; nd=0; ef=0
for rel in $(grep '^MOVED ' "$B" | awk '{print $2}' | sort -u); do
    n=$((n+1))
    key=$(echo "$rel" | sed 's|^\./||; s|/|__|g; s|\.sv$||')
    src="$SCR/tree/${rel#./}"
    g="$SCR/gold/$key"; mkdir -p "$g"
    # 1. DETERMINISM CONTROL on the PRISTINE binary
    mkdir -p "$g/d1" "$g/d2"
    ( cd "$(dirname "$src")" && timeout 120 "$A" "$(basename "$src")" -o "$g/d1/x.uhdm" > "$g/d1.log" 2>&1 </dev/null )
    ( cd "$(dirname "$src")" && timeout 120 "$A" "$(basename "$src")" -o "$g/d2/x.uhdm" > "$g/d2.log" 2>&1 </dev/null )
    det=DET
    if [ -f "$g/d1/x.uhdm" ] && [ -f "$g/d2/x.uhdm" ]; then
        cmp -s "$g/d1/x.uhdm" "$g/d2/x.uhdm" || det=NONDET
    else
        det=NODB
    fi
    # golden
    ( cd "$(dirname "$src")" && "$SL" -parse -nobuiltin -nocache -sv \
        "$(basename "$src")" > "$g/sl.log" 2>&1 </dev/null )
    grc=$?
    gdb=$(ls "$(dirname "$src")"/slpp_all/surelog.uhdm 2>/dev/null | head -1)
    if [ "$grc" != 0 ] || [ -z "$gdb" ]; then
        echo "ARM $rel  $det  SURELOG rc=$grc  NO GOLDEN — error recovery, not golden" >> "$OUT"
        ef=$((ef+1)); continue
    fi
    "$DUMP" "$gdb" > "$g/golden.dump" 2>/dev/null
    sed "s#$(dirname "$src")#WD#g" "$g/golden.dump" | sort > "$g/golden.sorted"
    for ev in def elab; do
        d="$SCR/run/$key.$ev"
        [ -f "$d/a.uhdm" ] && [ -f "$d/b.uhdm" ] || continue
        "$CMP" "$gdb" "$d/a.uhdm" > "$g/$ev.cmp.pris" 2>&1; r1=$?
        "$CMP" "$gdb" "$d/b.uhdm" > "$g/$ev.cmp.pat"  2>&1; r2=$?
        l1=$(wc -l < "$g/$ev.cmp.pris"); h1=$(grep -c '^LHS:' "$g/$ev.cmp.pris"; true)
        l2=$(wc -l < "$g/$ev.cmp.pat");  h2=$(grep -c '^LHS:' "$g/$ev.cmp.pat"; true)
        "$DUMP" "$d/a.uhdm" 2>/dev/null | sed "s#$(dirname "$src")#WD#g" | sort > "$g/$ev.pris.sorted"
        "$DUMP" "$d/b.uhdm" 2>/dev/null | sed "s#$(dirname "$src")#WD#g" | sort > "$g/$ev.pat.sorted"
        o1=$(diff "$g/golden.sorted" "$g/$ev.pris.sorted" | grep -c '^[<>]'; true)
        o2=$(diff "$g/golden.sorted" "$g/$ev.pat.sorted"  | grep -c '^[<>]'; true)
        v="SAME"
        if [ "$h2" -lt "$h1" ] || { [ "$h1" = "$h2" ] && [ "$l2" -lt "$l1" ]; } || [ "$o2" -lt "$o1" ]; then
            v="TO-GOLDEN"; tg=$((tg+1))
        elif [ "$h2" -gt "$h1" ] || { [ "$h1" = "$h2" ] && [ "$l2" -gt "$l1" ]; } || [ "$o2" -gt "$o1" ]; then
            v="!! AWAY-GOLDEN"; aw=$((aw+1))
        else
            sm=$((sm+1))
        fi
        [ "$det" = NONDET ] && nd=$((nd+1))
        printf "ARM %-42s %-5s %-6s cmp %s/%s -> %s/%s (rc %s->%s)  orderblind %s -> %s  %s\n" \
            "$rel" "$ev" "$det" "$l1" "$h1" "$l2" "$h2" "$r1" "$r2" "$o1" "$o2" "$v" >> "$OUT"
    done
done
echo "-- MOVED ARM-FILES $n  TO-GOLDEN $tg  SAME $sm  AWAY-GOLDEN $aw  NONDET-VIEWS $nd  NO-GOLDEN $ef" >> "$OUT"
tail -1 "$OUT"
