#!/usr/bin/env bash
# r11u121 order-blind whole-dump distance per arm: usage dist121.sh <pris outroot> <law outroot>
# prints: arm  d187(pris->law)  dds(pris->law)  [TO|AWAY|SAME]  where d = lines of the sorted-dump diff vs golden
set -u
P=$1; L=$2
nd() { $UHDM_DUMP "$1" 2>/dev/null | sed -E 's#file:[^,]*,#file:F,#; s#/tmp/[^ ]*##g' | sort; }
for a in $(cd "$P" && find . -name ours.uhdm -printf '%h\n' | sort); do
  g=$P/$a/g187.uhdm; gd=$P/$a/gds.uhdm
  p1=$(diff <(nd $g) <(nd $P/$a/ours.uhdm) | grep -c '^[<>]'); l1=$(diff <(nd $g) <(nd $L/$a/ours.uhdm) | grep -c '^[<>]')
  p2=$(diff <(nd $gd) <(nd $P/$a/ours_ds.uhdm) | grep -c '^[<>]'); l2=$(diff <(nd $gd) <(nd $L/$a/ours_ds.uhdm) | grep -c '^[<>]')
  v=SAME; { [ $l1 -lt $p1 ] || [ $l2 -lt $p2 ]; } && v=TO; { [ $l1 -gt $p1 ] || [ $l2 -gt $p2 ]; } && v=AWAY
  { [ $l1 -lt $p1 ] || [ $l2 -lt $p2 ]; } && { [ $l1 -gt $p1 ] || [ $l2 -gt $p2 ]; } && v=MIXED
  echo "${a#./} d187=$p1->$l1 dds=$p2->$l2 $v"
done
