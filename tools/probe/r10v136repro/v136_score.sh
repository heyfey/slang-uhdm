#!/usr/bin/env bash
# AWAY / MOVED-WRONG scorer over a golden/pristine/patched triple of dumps.
set -u
D=$1
for view in "g o q" "ge oe qe"; do
  set -- $view
  [ -f "$D/$1.uhdm" ] && [ -f "$D/$2.uhdm" ] && [ -f "$D/$3.uhdm" ] || { echo "$D $1 SKIP"; continue; }
  bash "$(dirname "${BASH_SOURCE[0]}")/v136_norm.sh" "$D/$1.uhdm" > "$D/$1.norm"
  bash "$(dirname "${BASH_SOURCE[0]}")/v136_norm.sh" "$D/$2.uhdm" > "$D/$2.norm"
  bash "$(dirname "${BASH_SOURCE[0]}")/v136_norm.sh" "$D/$3.uhdm" > "$D/$3.norm"
  NEWWRONG=$(comm -23 <(comm -23 "$D/$3.norm" "$D/$1.norm") "$D/$2.norm" | grep -c .; true)
  LOSTRIGHT=$(comm -23 <(comm -12 "$D/$1.norm" "$D/$2.norm") "$D/$3.norm" | grep -c .; true)
  FIXED=$(comm -23 <(comm -12 "$D/$1.norm" "$D/$3.norm") "$D/$2.norm" | grep -c .; true)
  echo "$(basename $D) view=$1 NEW_WRONG=$NEWWRONG LOST_RIGHT=$LOSTRIGHT NEWLY_AGREEING=$FIXED"
done
