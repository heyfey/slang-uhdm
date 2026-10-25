#!/bin/bash
# grid3.sh <verified> <law> <pristine> <casedir>...: one line per case dir (exit codes recorded):
#   case | law | pristine | law | verified | R11U430_OFF on verified == pristine | R11V430_OFF on verified == law | own switch on verified == pristine (a 430v refinement's own switch == law)
R=$(cd $(dirname $0)/.. && pwd); V=$1; L=$2; P=$3; shift 3
[ -x "$V" ] && [ -x "$L" ] && [ -x "$P" ] || exit 2
O=/tmp/v11u430_scr/out
m() { md5sum < $O/$1/$2/ours.uhdm 2>/dev/null | cut -c1-8; echo -n; }
for c in "$@"; do
  [ -d $c ] && [ -f $c/dut.sv ] || { echo "SKIP $c"; continue; }
  c=$(cd $c && pwd); g=$(basename $(dirname $c)); n=$(basename $c); key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
  law=$(head -1 $c/dut.sv | sed 's|^// § *||; s| .*||'); sw=$(awk -v l=$law '$1==l{print $2}' $R/drivers/switches.txt)
  p=$(bash $R/drivers/run1.sh $c $P p | cut -d' ' -f2-)
  l=$(bash $R/drivers/run1.sh $c $L l | cut -d' ' -f2-)
  v=$(bash $R/drivers/run1.sh $c $V v | cut -d' ' -f2-)
  bash $R/drivers/run1.sh $c $V o R11U430_OFF=1 >/dev/null
  bash $R/drivers/run1.sh $c $V f R11V430_OFF=1 >/dev/null
  bash $R/drivers/run1.sh $c $V s ${sw:-R11U430_NONE}=1 >/dev/null
  rc() { cat $O/$key/$1/rc; }
  eq() { [ "$(m $key $1)" = "$(m $key $2)" ] && [ "$(rc $1)" = "$(rc $2)" ] && echo same || echo DIFF; }
  # a verifier refinement's own switch gives the LAW's bytes; a law's own switch pristine's
  case $law in *430v) own=$(eq s l);; *) own=$(eq s p);; esac
  echo "$g/$n | $law | pristine $p | law $l | verified $v | OFF $(eq o p) | V430OFF $(eq f l) | $sw $own"
done
