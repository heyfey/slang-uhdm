#!/bin/bash
# vgrid.sh <pristine> <law> <verified> <casedir>...: per case: pristine | law | verified readings,
# R11U418_OFF on verified == pristine, R11V418_OFF on verified == law (bytes and exit code)
D=$(cd $(dirname $0) && pwd); P=$1; L=$2; V=$3; shift 3; O=/tmp/v11u418_scr/out
for c in "$@"; do
  [ -d "$c" ] || { echo "SKIP non-dir $c"; continue; }
  c=$(cd $c && pwd); key=$(echo $c | sed 's|.*/cases/||; s|/|_|g'); [ -n "$PFX" ] && key=$PFX$key
  p=$(bash $D/run1.sh $c $P p | cut -d' ' -f2-); l=$(bash $D/run1.sh $c $L l | cut -d' ' -f2-); v=$(bash $D/run1.sh $c $V v | cut -d' ' -f2-)
  bash $D/run1.sh $c $V vo R11U418_OFF=1 >/dev/null; bash $D/run1.sh $c $V vf R11V418_OFF=1 >/dev/null
  m(){ md5sum < $O/$key/$1/ours.uhdm 2>/dev/null | cut -c1-8; echo -n; }; r(){ cat $O/$key/$1/rc; }
  so=$([ "$(m vo)$(r vo)" = "$(m p)$(r p)" ] && echo same || echo DIFF); sf=$([ "$(m vf)$(r vf)" = "$(m l)$(r l)" ] && echo same || echo DIFF)
  echo "$(echo $c | sed 's|.*/cases/||') | pristine $p | law $l | verified $v | R11U418_OFF=pristine $so | R11V418_OFF=law $sf"
done
