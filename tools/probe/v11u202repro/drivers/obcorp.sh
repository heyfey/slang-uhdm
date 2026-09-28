#!/bin/bash
# v11u202: order-blind uhdm-dump census (ids and paths stripped) of corpus movers: golden vs pristine vs each other mirror.
# usage: obcorp.sh <moverlist> <sweepdirP> <mirrorP> <mirrorX>...   prints per mover: obdist and LOST/GAINED line counts
source "$(dirname "$0")/env.sh" || exit 3
L=$1; SP=$2; MP=$3; shift 3; T=/tmp/v11u202_obcorp; mkdir -p $T
while read -r p; do
  echo "$p" | grep -Pq "$FENCERE" && { echo "FENCED refused"; continue; }
  g=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' $SP/$(dirname $p)/cmds.txt | head -1); gu=$(ls $g/*.uhdm | head -1)
  $UHDM_DUMP $gu 2>/dev/null > $T/g.dump; $UHDM_DUMP $MP/$p 2>/dev/null > $T/p.dump
  line="$(dirname $p)"
  for MX in "$@"; do $UHDM_DUMP $MX/$p 2>/dev/null > $T/x.dump; line="$line | $(basename $MX): $(python3 "$(dirname "$0")/ob.py" $T/g.dump $T/p.dump $T/x.dump)"; done
  echo "$line"
done < $L
