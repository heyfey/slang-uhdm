#!/bin/bash
# rc.sh <case dir with dut.sv> [bin...]: golden (probe flags) per dir+text; ours per bin; uhdm-cmp lines + strict verdict
source /tmp/v11u147_env.sh
d=$(cd "$1" && pwd); shift
fre=$(echo $FENCED | sed 's/ /|/g'); echo "$d" | grep -Eqw "$fre" && { echo "FENCED-SKIP $d"; exit 3; }
BINS=${@:-/tmp/v11u147_bin/pris}
g=/tmp/v11u147_s/gold/$(cat $d/*.sv | md5sum | cut -c1-8)_$(echo $d | md5sum | cut -c1-12)
if [ ! -f $g/g.uhdm ]; then rm -rf $g; mkdir -p $g/o
  (cd $d && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $g/o >$g/sl.log 2>&1); f=$(find $g/o -name '*.uhdm' | head -1); cp "$f" $g/g.uhdm 2>/dev/null; fi
mkdir -p /tmp/v11u147_s/ours
for b in $BINS; do o=/tmp/v11u147_s/ours/$(echo $d$b$R11U147_OFF | md5sum | cut -c1-12).uhdm; rm -f $o
  (cd $d && $b dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1); rc=$?
  n=$($UHDM_CMP $g/g.uhdm $o 2>&1 | grep -c .)
  s=$($STRICT_CMP --max ${MAX:-3} $g/g.uhdm $o 2>&1 | tail -${TAILN:-1})
  echo "$(basename $d) $(basename $b) rc=$rc cmp=$n | $s"
  [ -n "$KEEP" ] && cp $o $KEEP.$(basename $b).uhdm && cp $g/g.uhdm $KEEP.gold.uhdm
done
