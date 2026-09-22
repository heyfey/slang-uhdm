#!/usr/bin/env bash
# r11u95 SWITCH LEDGER + INERTNESS.  usage: GRID=<dir> sw95.sh <pristine> <law>
# Sums the official cmp lines over every buildable arm of GRID for each switch,
# and (with R11U95_OFF=1) compares the two binaries' DATABASES byte for byte.
set -u
GRID=${GRID:?set GRID}
P=${1:?pristine}; L=${2:?law}
CMP=${CMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp}
ARMS=$(ls -d $GRID/*/ | xargs -n1 basename | sort -V)
score() { # $1 = binary, $2... = env ; writes sw95.<tag>.uhdm per arm
  local bin=$1 tag=$2; shift 2
  local tot=0
  for a in $ARMS; do
    d=$GRID/$a
    [ -f "$d/slpp_all/surelog.uhdm" ] || continue
    rm -f $d/sw95.$tag.uhdm
    ( cd $d && env "$@" $bin dut.sv --single-unit --nobuiltin -o sw95.$tag.uhdm >/dev/null 2>&1 )
    [ -f "$d/sw95.$tag.uhdm" ] || continue
    n=$($CMP $d/slpp_all/surelog.uhdm $d/sw95.$tag.uhdm 2>/dev/null | wc -l)
    tot=$((tot+n))
  done
  echo $tot
}
printf '%-32s %s\n' "pristine"             "$(score $P pris DUMMY95=0)"
printf '%-32s %s\n' "law, all switches ON" "$(score $L lawx DUMMY95=0)"
for sw in R11U95_OFF R11U95_PROGPROC_OFF R11U95_PROGTF_OFF R11U95_PROGCLASS_OFF \
          R11U95_PROGTFINST_OFF R11U95_GENZERO_OFF; do
  printf '%-32s %s\n' "$sw=1" "$(score $L ${sw#R11U95_} $sw=1)"
done
# INERTNESS: with every r11u95 switch off the law binary's database must be
# BYTE-IDENTICAL to the pristine binary's on every buildable arm.
same=0; diff=0; miss=0
for a in $ARMS; do
  d=$GRID/$a
  if [ -f "$d/sw95.pris.uhdm" ] && [ -f "$d/sw95.OFF.uhdm" ]; then
    if cmp -s $d/sw95.pris.uhdm $d/sw95.OFF.uhdm; then same=$((same+1)); else diff=$((diff+1)); echo "  BYTE-DIFF $a"; fi
  else miss=$((miss+1)); fi
done
echo "R11U95_OFF=1 vs pristine DATABASES: identical=$same differing=$diff unbuilt=$miss"
