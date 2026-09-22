#!/usr/bin/env bash
# r11u93 SWITCH LEDGER. usage: GRID=<dir> sw93.sh <pristine> <law>
set -u
GRID=${GRID:?set GRID}
P=${1:?pristine}; L=${2:?law}
CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
ARMS=$(ls -d $GRID/*/ | xargs -n1 basename | sort -V)
score() { # $1 = binary, $2... = env
  local bin=$1; shift
  local tot=0
  for a in $ARMS; do
    d=$GRID/$a
    [ -f "$d/slpp_all/surelog.uhdm" ] || continue
    ( cd $d && env "$@" $bin dut.sv --single-unit --nobuiltin -o sw93.uhdm >/dev/null 2>&1 )
    [ -f "$d/sw93.uhdm" ] || continue
    n=$($CMP $d/slpp_all/surelog.uhdm $d/sw93.uhdm 2>/dev/null | wc -l)
    tot=$((tot+n))
  done
  echo $tot
}
echo "pristine                       $(score $P DUMMY93=0)"
echo "law, all switches ON           $(score $L DUMMY93=0)"
for sw in R11U93_OFF R11U93_IFPORTMINT_OFF R11U93_IFPORTORD_OFF R11U93_IFPORTLOW_OFF R11U93_IFPORTTYPE_OFF R11U93_PROGGEN_OFF R11U93_PROGFLAT_OFF; do
  printf '%-30s %s\n' "$sw=1" "$(score $L $sw=1)"
done
