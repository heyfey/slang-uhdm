#!/bin/bash
# usage: grid3.sh <pristine> <law> <verified> <out root> <case dir>...
# per case: upstream slang exit; pristine, law, verified readings; R11U435_OFF on verified == pristine bytes;
# R11V435_OFF on verified == law bytes
P=$1; L=$2; V=$3; O=$4; shift 4
H=$(dirname $(readlink -f $0))
SLANG=$HOME/.local/bin/slang
[ -x "$SLANG" ] || { echo "missing slang"; exit 9; }
for c in "$@"; do
  c=$(readlink -f $c); k=$(basename $(dirname $c))/$(basename $c)
  sl=$( (cd $c && $SLANG dut.sv --single-unit -q >/dev/null 2>&1 </dev/null); echo $?)
  a=$($H/runcase.sh $c $P $O/$k/pris)
  for d in law ver uoff voff; do mkdir -p $O/$k/$d; cp -f $O/$k/pris/golden.uhdm $O/$k/pris/golden.dump $O/$k/$d/ 2>/dev/null; done
  b=$($H/runcase.sh $c $L $O/$k/law)
  v=$($H/runcase.sh $c $V $O/$k/ver)
  u=$(R11U435_OFF=1 $H/runcase.sh $c $V $O/$k/uoff)
  w=$(R11V435_OFF=1 $H/runcase.sh $c $V $O/$k/voff)
  m(){ echo "$1" | grep -o 'md5=[^ ]*'; }
  echo "$k slang=$sl | PRIS $a | LAW $b | VER $v | UOFF_eq_pris=$([ "$(m "$a")" = "$(m "$u")" ] && echo yes || echo NO) VOFF_eq_law=$([ "$(m "$b")" = "$(m "$w")" ] && echo yes || echo NO)"
done
