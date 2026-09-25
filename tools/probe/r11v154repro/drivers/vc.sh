#!/bin/bash
# vc.sh <case dir> [bin...] : golden (probe flags), ours per bin with env passthrough; prints rc, uhdm-cmp lines, strict verdict
source "$(dirname "$0")/env.sh"  # FENCED must come from the caller's environment
d=$(cd "$1" && pwd); shift
BINS=${@:-"$PRIS $LAW"}
[ -n "$FENCED" ] || { echo "FENCED unset: refusing"; exit 2; }; for f in $FENCED; do case "$d" in *"$f"*) echo "FENCED: refuse"; exit 2;; esac; done
k=$(cat $d/dut.sv | md5sum | cut -c1-10)_$(echo $d | md5sum | cut -c1-10)
g=/tmp/v11u154_gold/$k
if [ ! -f $g/g.uhdm ]; then rm -rf $g; mkdir -p $g/o
  (cd $d && timeout 300 $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $g/o >$g/sl.log 2>&1); echo $? > $g/rc
  f=$(find $g/o -name '*.uhdm' | head -1); [ -n "$f" ] && cp "$f" $g/g.uhdm; fi
[ -f $g/g.uhdm ] || { echo "$(basename $(dirname $d))/$(basename $d) NOGOLDEN rc=$(cat $g/rc)"; exit 0; }
line="$(basename $(dirname $d))/$(basename $d)"
for b in $BINS; do tag=$(basename $b .bin)${VCTAG:+_$VCTAG}
  o=/tmp/v11u154_ours/$k/$tag.uhdm; mkdir -p $(dirname $o); rm -f $o
  (cd $d && timeout 300 $b dut.sv --single-unit --nobuiltin -o $o >$o.log 2>&1); rc=$?
  if [ -f $o ]; then n=$($UHDM_CMP $g/g.uhdm $o 2>&1 | grep -c .); s=$(timeout 300 $STRICT_CMP --max ${MAX:-1} $g/g.uhdm $o 2>&1 | tail -1); else n=NA; s=NOOUT; fi
  line="$line | $tag rc=$rc cmp=$n $s"
done
echo "$line"
