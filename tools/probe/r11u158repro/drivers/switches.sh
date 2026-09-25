#!/bin/bash
# switches.sh <law bin>: every case of cases/ under each single switch; prints the cases whose verdict
# differs from the all-on verdict (they must be exactly the switch's own law cases).
L=$1; D=$(cd $(dirname $0) && pwd); cd $D
for c in ../cases/*/*; do echo "$c $(./grid.sh $c $L ON | awk '{print $5}')"; done > /tmp/r11u158_sw_on.txt
for sw in R11U157_ROUTE_OFF R11U157_THIS_OFF R11U157_FOREACH_OFF R11U157_GENTGT_OFF R11U158_EVALIASEND_OFF R11U158_GCALHSENUM_OFF R11U158_SCLITMASK_OFF R11U158_SCSIGNSIZE_OFF R11U158_PKGLPAREN_OFF R11U158_ARRQRYLOC_OFF R11U158_AGGUNQSPAN_OFF R11U158_RANDSPAN_OFF; do
  ch=""
  while read c v; do
    w=$(./grid.sh $c $L SW_$sw $sw=1 | awk '{print $5}')
    [ "$w" != "$v" ] && ch="$ch $(echo $c | sed 's#../cases/##')"
  done < /tmp/r11u158_sw_on.txt
  echo "$sw:$ch"
done
