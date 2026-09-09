#!/bin/bash
# r10v226 — THREE-WAY arm runner: golden Surelog + pristine slang + patched slang.
# Every arm's rc on all three sides is printed.  LISTED/PROCESSED asserted.
# usage: bash /tmp/v226_run.sh <armroot> <outdir>
set -u
SL=$HOME/git-repos/Surelog/build/bin/surelog          # the path verify_golden.py names
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
PRIS=${PRIS:-/tmp/v226_bin/pris.bin}
PAT=${PAT:-/tmp/v226_bin/pat.bin}
ARMS=${1:?armroot}
OUT=${2:?outdir}
mkdir -p "$OUT"
echo "v226run: surelog=$SL"
echo "v226run: pris=$PRIS md5=$(md5sum "$PRIS" | cut -c1-12)"
echo "v226run: pat =$PAT  md5=$(md5sum "$PAT"  | cut -c1-12)"
listed=0; processed=0
exec 3< <(ls -d "$ARMS"/*/ | sort)
while read -r a <&3; do listed=$((listed+1)); done
exec 3<&-
exec 3< <(ls -d "$ARMS"/*/ | sort)
while read -r a <&3; do
    n=$(basename "$a")
    f="$a/dut.sv"
    [ -f "$f" ] || { echo "ARM $n  NO-DUT"; continue; }
    d="$OUT/$n"; mkdir -p "$d/g" "$d/p" "$d/q"
    ( cd "$d/g" && "$SL" -parse -nobuiltin -nocache -sv "$f" > sl.log 2>&1 </dev/null ); grc=$?
    ( cd "$d/p" && "$PRIS" "$f" -o slang.uhdm > o.log 2>&1 </dev/null );             prc=$?
    ( cd "$d/q" && "$PAT"  "$f" -o slang.uhdm > o.log 2>&1 </dev/null );             qrc=$?
    gdb=$(ls "$d/g"/slpp_all/surelog.uhdm 2>/dev/null | head -1)
    [ -n "$gdb" ] && "$DUMP" "$gdb"          > "$d/golden.dump" 2>/dev/null
    [ -f "$d/p/slang.uhdm" ] && "$DUMP" "$d/p/slang.uhdm" > "$d/pris.dump" 2>/dev/null
    [ -f "$d/q/slang.uhdm" ] && "$DUMP" "$d/q/slang.uhdm" > "$d/pat.dump"  2>/dev/null
    gl=$( [ -f "$d/golden.dump" ] && wc -l < "$d/golden.dump" || echo 0 )
    pl=$( [ -f "$d/pris.dump" ]   && wc -l < "$d/pris.dump"   || echo 0 )
    ql=$( [ -f "$d/pat.dump" ]    && wc -l < "$d/pat.dump"    || echo 0 )
    same=SAME
    if [ -f "$d/pris.dump" ] && [ -f "$d/pat.dump" ]; then
        sed "s|$d/p|WD|g" "$d/pris.dump" > "$d/pris.n"
        sed "s|$d/q|WD|g" "$d/pat.dump"  > "$d/pat.n"
        cmp -s "$d/pris.n" "$d/pat.n" || same=MOVED
    else
        same=NODUMP
    fi
    printf 'ARM %-22s g_rc=%s(%s)  pris_rc=%s(%s)  pat_rc=%s(%s)  %s\n' \
        "$n" "$grc" "$gl" "$prc" "$pl" "$qrc" "$ql" "$same"
    [ "$grc" != 0 ] && echo "  !! GOLDEN NONZERO RC — error recovery, not golden"
    [ "$prc" != 0 ] && echo "  !! PRISTINE NONZERO RC"
    [ "$qrc" != 0 ] && echo "  !! PATCHED NONZERO RC"
    processed=$((processed+1))
done
exec 3<&-
echo "v226run: LISTED $listed PROCESSED $processed"
[ "$listed" = "$processed" ] || echo "  !! LISTED != PROCESSED"
