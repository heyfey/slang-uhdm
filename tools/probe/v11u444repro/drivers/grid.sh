#!/bin/bash
# grid.sh <casedir>...: per case: pristine | law | (verified if VER set) | R11U444_OFF==pristine | own switches==pristine | dump distances
# binaries: /tmp/v11u444_bin/{pristine,law,ver}; switches from ../../r11u444repro/drivers/switches.txt (+ ./switches.txt)
R=$(cd $(dirname $0)/.. && pwd); S=$R/../r11u444repro/drivers/switches.txt
P=/tmp/v11u444_bin/pristine; L=/tmp/v11u444_bin/law; V=${VER:-}
for c in "$@"; do
  [ -d $c ] && [ -f $c/dut.sv ] || { echo "SKIP $c"; continue; }
  c=$(cd $c && pwd); key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
  law=$(head -1 $c/dut.sv | sed 's|^// § *||; s| .*||')
  sw=$(cat $S $R/drivers/switches.txt 2>/dev/null | awk -v l=$law '$1==l{for(i=2;i<=NF;i++) printf "%s=1 ", $i}')
  p=$(bash $R/drivers/run1.sh $c $P p | cut -d' ' -f2-)
  l=$(bash $R/drivers/run1.sh $c $L l | cut -d' ' -f2-)
  bash $R/drivers/run1.sh $c $L o R11U444_OFF=1 >/dev/null
  bash $R/drivers/run1.sh $c $L s ${sw:-R11U444_NONE=1} >/dev/null
  O=/tmp/v11u444_scr/out/$key
  m(){ md5sum < $O/$1/ours.uhdm 2>/dev/null | cut -c1-8; }
  dp=$(bash $R/drivers/dist.sh $c p); dl=$(bash $R/drivers/dist.sh $c l)
  vv=; if [ -n "$V" ]; then v=$(bash $R/drivers/run1.sh $c $V v | cut -d' ' -f2-); dv=$(bash $R/drivers/dist.sh $c v); vv=" | ver $v dist $dv"; fi
  echo "$key | pris $p dist $dp | law $l dist $dl$vv | OFF $([ "$(m o)" = "$(m p)" ] && [ "$(cat $O/o/rc)" = "$(cat $O/p/rc)" ] && echo same || echo DIFF) | own $([ "$(m s)" = "$(m p)" ] && [ "$(cat $O/s/rc)" = "$(cat $O/p/rc)" ] && echo same || echo DIFF)"
done
