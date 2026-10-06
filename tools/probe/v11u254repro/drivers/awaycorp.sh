#!/bin/bash
# (v11u254: copied from r11u254repro/drivers)
# (r11u254: copied from r11u255repro/drivers)
# (r11u255: copied from r11u253repro/drivers)
# (r11u253: copied from r11u251repro/drivers)
# (r11u251) awaycorp.sh <pristine sweep wd> <law sweep wd> <moverlist> <outdir>: the order-blind AWAY census
# (drivers/away.py) of each listed corpus mover (`surelog/<mode>/<test>-<hash>` per line) against its cached
# golden. Needs drivers/env.sh sourced; a fenced name is refused before any file is opened.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "awaycorp.sh: FENCED unset" >&2; exit 2; }
P=$1; L=$2; M=$3; O=$4; mkdir -p $O
export SCMP=${STRICT_CMP:?}
while read -r p; do
  echo "$p" | grep -qwE "$(echo $FENCED | tr ' ' '|')" && { echo "$p FENCED-REFUSED"; continue; }
  g=$(grep -o 'golden cache [a-z]* [^)]*' $P/$p/cmds.txt | awk '{print $4}')/golden.uhdm
  t=$O/$(echo $p | tr '/' '_'); mkdir -p $t
  python3 "$(dirname "$0")/away.py" $g $P/$p/slang.uhdm $L/$p/slang.uhdm $t v > $t/away.txt
  echo "$p $(head -1 $t/away.txt)"
done < $M
