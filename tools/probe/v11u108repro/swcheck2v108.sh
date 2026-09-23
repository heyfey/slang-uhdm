#!/bin/bash
# swcheck2v108.sh <out-root>... : switch identities for the verified binary (fix2)
#   loff==pris ; f2loff(R11U108_OFF on fix2)==pris ; f2off(V11U108_FIX_OFF)==lawx ; movers lawx!=pris, fix2!=lawx
#   fx5off / fx2off / f2tpoff / f2pkoff: the arms each single switch moves off fix2
for R in "$@"; do
  n=0; a1=0; a2=0; a3=0; ml=""; mf=""; x5=""; x2=""; tp=0; pk=0
  while read -r d; do
    w=$(dirname "$d"); [ -f "$w/pris.uhdm" ] || continue; n=$((n+1)); a=${w#$R/}
    s(){ cmp -s "$w/$1.uhdm" "$w/$2.uhdm"; }
    s loff pris && a1=$((a1+1)); s f2loff pris && a2=$((a2+1)); s f2off lawx && a3=$((a3+1))
    s lawx pris || ml="$ml $a"; s fix2 lawx || mf="$mf $a"
    s fx5off fix2 || x5="$x5 $a"; s fx2off fix2 || x2="$x2 $a"
    s f2tpoff fix2 || tp=$((tp+1)); s f2pkoff fix2 || pk=$((pk+1))
  done < <(find "$R" -name pris.uhdm | sort)
  echo "$R arms=$n loff==pris:$a1 f2loff==pris:$a2 f2off==lawx:$a3 tpoff-moves:$tp pkoff-moves:$pk"
  echo "  law movers ($(echo $ml | wc -w))"
  echo "  fix2 movers vs law ($(echo $mf | wc -w)):$mf"
  echo "  FIX5_OFF moves ($(echo $x5 | wc -w)):$x5"
  echo "  FIX2_OFF moves ($(echo $x2 | wc -w)):$x2"
done
