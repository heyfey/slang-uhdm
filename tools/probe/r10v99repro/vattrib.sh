#!/usr/bin/env bash
# v99 verifier: order-blind + ordered whole-dump attribution of one mover.
set -u
REL=$1; PATWD=$2; PRISWD=$3
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
O=/tmp/v99_attrib/$(echo "$REL" | tr '/' '_')
mkdir -p "$O"
for t in pat pris; do
  wd=$PATWD; [ $t = pris ] && wd=$PRISWD
  "$DUMP" "$wd/$REL" 2>/dev/null \
    | sed -e "s|$PATWD||g; s|$PRISWD||g" -e 's/, id:[0-9]*//g' > "$O/$t.dump"
done
ord=$(diff "$O/pris.dump" "$O/pat.dump" | grep -c '^[<>]'; true)
sort "$O/pris.dump" > "$O/pris.s"; sort "$O/pat.dump" > "$O/pat.s"
ob=$(diff "$O/pris.s" "$O/pat.s" | grep -c '^[<>]'; true)
echo "$REL ordered=$ord order_blind=$ob"
