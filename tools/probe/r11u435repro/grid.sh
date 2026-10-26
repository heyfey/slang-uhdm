#!/bin/bash
# usage: grid.sh <pristine bin> <law bin> <out root> <case dir>...
# one line per case: exit codes, uhdm-cmp line counts, strict verdicts, md5s
# for pristine, law, and the law binary under R11U435_OFF (must equal pristine).
P=$1; L=$2; O=$3; shift 3
H=$(dirname $(readlink -f $0))
SLANG=$HOME/.local/bin/slang
for c in "$@"; do
  c=$(readlink -f $c); k=$(basename $(dirname $c))/$(basename $c)
  sl=$( (cd $c && $SLANG dut.sv --single-unit -q >/dev/null 2>&1 </dev/null); echo $?)
  a=$($H/runcase.sh $c $P $O/$k/pris)
  mkdir -p $O/$k/law $O/$k/off; cp -f $O/$k/pris/golden.uhdm $O/$k/pris/golden.dump $O/$k/law/ 2>/dev/null; cp -f $O/$k/pris/golden.uhdm $O/$k/pris/golden.dump $O/$k/off/ 2>/dev/null
  b=$($H/runcase.sh $c $L $O/$k/law)
  d=$(R11U435_OFF=1 $H/runcase.sh $c $L $O/$k/off)
  pm=$(echo "$a" | grep -o 'md5=[^ ]*'); om=$(echo "$d" | grep -o 'md5=[^ ]*')
  echo "$k slang=$sl | PRIS $a | LAW $b | OFF_eq_pris=$([ "$pm" = "$om" ] && echo yes || echo NO)"
done
