#!/bin/bash
set -u
A=$(readlink -f "$1"); BIN="$2"; TAG="$3"
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
W="$A/w_$TAG"; rm -rf "$W"; mkdir -p "$W"
SRCS=$(cd "$A" && ls *.sv 2>/dev/null)
( cd "$A" && "$SL" -parse -nobuiltin -nocache -sv -mt 0 -mp 0 -o "$W" $SRCS > "$W/sl.log" 2>&1 ); echo "SURELOG rc=$?"
grep -oE '\[ *ERROR\] *: *[0-9]+' "$W/sl.log" | tail -n 1
G=$(ls "$W"/slpp_all/*.uhdm 2>/dev/null | head -1)
[ -z "$G" ] && { echo "NO GOLDEN"; tail -5 "$W/sl.log"; exit 2; }
( cd "$A" && "$BIN" $SRCS -o "$W/slang.uhdm" > "$W/su.log" 2>&1 ); echo "SLANG rc=$?"
[ -f "$W/slang.uhdm" ] || { echo "NO SLANG DB"; tail -8 "$W/su.log"; exit 3; }
"$DUMP" "$G" | tail -n +2 > "$W/golden.dump"
"$DUMP" "$W/slang.uhdm" | tail -n +2 > "$W/ours.dump"
"$CMP" "$G" "$W/slang.uhdm" > "$W/cmp.out" 2> "$W/cmp.err"; echo "CMP rc=$?"
echo "HEADS=$(grep -c '^LHS:' "$W/cmp.err"; true)"
head -6 "$W/cmp.err" 2>/dev/null
