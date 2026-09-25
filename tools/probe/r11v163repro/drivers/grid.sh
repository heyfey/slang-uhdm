#!/bin/bash
# v11u163_grid.sh <casedir> [ENV=VAL ...] : golden (pinned Surelog, check_probe's args) + pristine + law, uhdm-cmp + strictcmp
source /tmp/v11u163_env.sh
c=$(realpath $1); shift
for n in $FENCED; do case "$c" in *$n*) echo "FENCED REFUSE $c"; exit 3;; esac; done
[ -n "$FENCED" ] || { echo "no FENCED"; exit 3; }
key=$(echo $c | sed 's#^/##; s#/#_#g')
w=/tmp/v11u163_g/$key; mkdir -p $w
g=$w/golden.uhdm
if [ ! -s $g ] || [ $c/dut.sv -nt $g ]; then
  rm -rf $w/gw; mkdir -p $w/gw; rm -f $g
  (cd $c && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $w/gw > $w/sl.log 2>&1)
  f=$(find $w/gw -name '*.uhdm' | head -1); [ -n "$f" ] && cp $f $g; rm -rf $w/gw
fi
line="$(basename $(dirname $c))/$(basename $c)"
for t in pris law; do
  o=$w/$t.uhdm; rm -f $o
  (cd $c && env "$@" /tmp/v11u163_bin/$t.bin dut.sv --single-unit --nobuiltin -o $o > $w/$t.log 2>&1); rc=$?
  if [ ! -s $g ]; then line="$line | SURELOG_FAIL"; break; fi
  if [ ! -s $o ]; then line="$line | $t: SLANG_FAIL rc=$rc"; continue; fi
  $UHDM_CMP $g $o > $w/$t.cmp 2>&1; cr=$?
  $STRICT_CMP --max 30 --dump-a $w/$t.a.txt --dump-b $w/$t.b.txt $g $o > $w/$t.strict 2>&1
  line="$line | $t: rc=$rc cmp=$cr/$(wc -l < $w/$t.cmp) $(tail -1 $w/$t.strict | tr ' ' _)"
done
cmp -s $w/pris.uhdm $w/law.uhdm && line="$line | BYTES_SAME" || line="$line | BYTES_DIFF"
echo "$line"
