#!/bin/bash
# swcheck108.sh <out-root>... : per arm, byte-compare tag pairs (switch identities + movers)
#   loff==pris floff==pris foff==lawx ; movers lawx!=pris, fixd!=lawx ; tpoff/pkoff single-law arms
for R in "$@"; do
  n=0; declare -A c=(); mv_law=""; mv_fix=""; tp=0; pk=0
  while read -r d; do
    w=$(dirname "$d"); [ -f "$w/pris.uhdm" ] || continue; n=$((n+1)); a=${w#$R/}
    s(){ cmp -s "$w/$1.uhdm" "$w/$2.uhdm"; }
    s loff pris && c[loff]=$((c[loff]+1)); s floff pris && c[floff]=$((c[floff]+1)); s foff lawx && c[foff]=$((c[foff]+1))
    s lawx pris || mv_law="$mv_law $a"; s fixd lawx || mv_fix="$mv_fix $a"
    # single switch: tpoff (fixd minus face5) must equal pris on face-5-only arms; count arms each switch restores
    s tpoff fixd || tp=$((tp+1)); s pkoff fixd || pk=$((pk+1))
  done < <(find "$R" -name pris.uhdm | sort)
  echo "$R arms=$n loff==pris:${c[loff]:-0} floff==pris:${c[floff]:-0} foff==lawx:${c[foff]:-0} tpoff-moves:$tp pkoff-moves:$pk"
  echo "  law movers ($(echo $mv_law | wc -w)):$mv_law"
  echo "  fix movers ($(echo $mv_fix | wc -w)):$mv_fix"
  unset c
done
