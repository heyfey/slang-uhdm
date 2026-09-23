#!/bin/bash
# score110.sh <grid-out-root> <before-tag> <after-tag>
# Per arm, per NAME-KEYED cell (cell110): golden-vs-before, golden-vs-after,
# before-vs-after.  Classes: TO-GOLDEN (NE->EQ), AWAY (EQ->NE), MOVED-WRONG
# (NE->NE with before != after), NEW-CELL/LOST-CELL, else unmoved.
# Prints one line per moved cell and a total.
ROOT=${1:?root}; B=${2:?before}; A=${3:?after}
C=${CELL110:-$(dirname "$0")/cell110}
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
tg=0; aw=0; mw=0; oth=0; arms=0
while read -r g <&3; do
  d=$(dirname "$g"); arm=${d#$ROOT/}
  [ -f "$d/$B.uhdm" ] && [ -f "$d/$A.uhdm" ] || continue
  arms=$((arms+1))
  "$C" "$g" "$d/$B.uhdm" </dev/null > "$d/cell.$B"
  "$C" "$g" "$d/$A.uhdm" </dev/null > "$d/cell.$A"
  "$C" "$d/$B.uhdm" "$d/$A.uhdm" </dev/null > "$d/cell.$B-$A"
  out=$(join -t'|' <(sed 's/ \([A-Z-]*\)$/|\1/' "$d/cell.$B" | sort) <(sed 's/ \([A-Z-]*\)$/|\1/' "$d/cell.$A" | sort) |
        join -t'|' - <(sed 's/ \([A-Z-]*\)$/|\1/' "$d/cell.$B-$A" | sort) |
        awk -F'|' -v arm="$arm" '
          $2=="NE" && $3=="EQ" {print arm" "$1" TO-GOLDEN"; next}
          $2=="EQ" && $3!="EQ" {print arm" "$1" AWAY"; next}
          $2=="NE" && $3=="NE" && $4!="EQ" {print arm" "$1" MOVED-WRONG"; next}
          $2!=$3 {print arm" "$1" OTHER "$2"->"$3}')
  [ -n "$out" ] && echo "$out"
  tg=$((tg+$(grep -c ' TO-GOLDEN$' <<<"$out"; true)))
  aw=$((aw+$(grep -c ' AWAY$' <<<"$out"; true)))
  mw=$((mw+$(grep -c ' MOVED-WRONG$' <<<"$out"; true)))
  oth=$((oth+$(grep -c ' OTHER ' <<<"$out"; true)))
done 3< <(find "$ROOT" -name gold.uhdm | sort)
echo "ARMS=$arms TO-GOLDEN=$tg AWAY=$aw MOVED-WRONG=$mw OTHER=$oth"
