#!/bin/bash
# v11u133_grid.sh <casesroot> <outdir> <bin> [ENV=VAL...]; golden cache /tmp/v11u133_gcache keyed by md5 of all case files
source /tmp/v11u133_env.sh
root=$1; out=$2; bin=$3; shift 3
GC=/tmp/v11u133_gcache; mkdir -p $GC $out
for c in $(find $root -name dut.sv | sort); do
  d=$(dirname $c); rel=${d#$root/}; name=${rel//\//__}
  h=$(cat $(find $d -type f ! -name LAW | sort) | md5sum | cut -c1-16)
  g=$GC/$h.uhdm
  if [ ! -s $g ]; then
    w=$(mktemp -d /tmp/v11u133_sl.XXXXXX)
    (cd $d && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $w >/dev/null 2>&1)
    f=$(find $w -name '*.uhdm' | head -1); [ -n "$f" ] && cp $f $g; rm -rf $w
  fi
  o=$out/$name.uhdm; rm -f $o
  (cd $d && env "$@" $bin dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1); rc=$?
  if [ ! -s $g ]; then echo "$rel NOGOLDEN rc=$rc"; continue; fi
  if [ ! -s $o ]; then echo "$rel SLANG_FAIL rc=$rc"; continue; fi
  cl=$($UHDM_CMP $g $o 2>&1 | wc -l)
  st=$(/tmp/v11u133_bin/strictcmp --max 0 $g $o 2>&1| tail -1)
  echo "$rel rc=$rc cmp=$cl $st"
  echo $g > $out/$name.golden
done
