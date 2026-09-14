#!/usr/bin/env bash
# r11u27 (inherited from r11u22): score the DIRECTION of a boundary mover — builds the REAL v1.87
# golden for the file and runs the OFFICIAL uhdm-cmp against BOTH binaries.
# usage: bndattr22.sh <file> [<file> ...]
set -u
PRIS=${PRIS:-/tmp/r11u27_bin/pris.bin}
LAW=${LAW:-/tmp/r11u27_bin/law2.bin}
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
OUT=${OUT:-/tmp/r11u27_bndattr}
mkdir -p $OUT
for f in "$@"; do
  key=$(echo "$f" | sed 's#^/##; s#/#_#g'); d=$OUT/$key; mkdir -p $d
  ( cd $d && rm -rf slpp_all && $SL -parse -nobuiltin -nocache -sv "$f" > sl.log 2>&1; echo $? > sl.rc )
  g=$d/slpp_all/surelog.uhdm
  line="$(basename $(dirname "$f"))/$(basename "$f")  golden_rc=$(cat $d/sl.rc)"
  for tag in pris law; do
    b=$PRIS; [ $tag = law ] && b=$LAW
    ( cd $(dirname "$f") && $b $(basename "$f") --single-unit --nobuiltin -o $d/$tag.uhdm > $d/$tag.log 2>&1 </dev/null; echo $? > $d/$tag.rc )
    rc=NA; cl=NA
    if [ -f "$g" ] && [ -f $d/$tag.uhdm ]; then
      $CMP "$g" $d/$tag.uhdm > $d/cmp.$tag.out 2> $d/cmp.$tag.err; rc=$?
      cl=$(wc -l < $d/cmp.$tag.out)
    fi
    line="$line  ${tag}_rc=$(cat $d/$tag.rc) cmp_rc=$rc cmplines=$cl"
  done
  echo "$line"
done
