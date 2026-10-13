# (v11u310: copied from r11u310repro/drivers, scratch paths renamed to /tmp/v11u310_*)
# (r11u310: copied from r11u308repro/drivers, renamed to R11U310 / r11u310)
# (r11u308: copied from r11u306repro/drivers, renamed to R11U308 / r11u308)
# (r11u308: copied from r11u304repro/drivers, renamed to R11U308 / r11u308)
# (r11u308: copied from r11u302repro/drivers, renamed to R11U308 / r11u308)
#!/bin/bash
# (r11u308: copied from r11u300repro/drivers, renamed to R11U308 / r11u308)
# (r11u286: copied from r11u287repro/drivers)
# (r11u287: copied from r11u285repro/drivers)
# (r11u285: copied from r11u283repro/drivers)
# (r11u283: copied from r11u281repro/drivers)
# (r11u279: copied from r11u277repro/drivers)
# (r11u277: copied from r11u275repro/drivers)
# (r11u275: copied from r11u273repro/drivers)
# (r11u273: copied from r11u271repro/drivers)
# (r11u271: copied from r11u269repro/drivers)
# (r11u269: copied from r11u267repro/drivers)
# (r11u267: copied from r11u265repro/drivers)
# (r11u265: copied from r11u263repro/drivers)
# (r11u263: copied from r11u261repro/drivers)
# (r11u261: copied from r11u259repro/drivers)
# (r11u259: copied from r11u257repro/drivers)
# (r11u257: copied from r11u255repro/drivers)
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
