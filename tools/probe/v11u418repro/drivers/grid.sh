#!/bin/bash
# grid.sh <law> <pristine> <casedir>...: per case: upstream slang rc | pristine | law | R11U418_OFF==pristine | own switch==pristine
# (explicit case directories only; never a glob of files)
D=$(cd $(dirname $0) && pwd); L=$1; P=$2; shift 2
declare -A SW=( [VK]=R11U418_KEPTTDNAMES_OFF [VP]=R11U418_PSBOUNDREF_OFF [VG]=R11U418_GENGATENET_OFF
  [VN]=R11U418_UNNAMEDGATETERM_OFF [VC]=R11U418_CLSTPUNITTD_OFF [VB]=R11U418_TDMOVEBITSEL_OFF
  [VI]=R11U418_IFCFILEIMP_OFF [VH]=R11U418_HOISTFIRSTMOD_OFF [VT]=R11U418_THISFIRSTMOD_OFF
  [VM]=R11U418_MPIMPLNETTYPE_OFF [VU]=R11U418_UNITVARNET_OFF )
O=/tmp/v11u418_scr/out
for c in "$@"; do
  [ -d "$c" ] || { echo "SKIP non-dir $c"; continue; }
  c=$(cd $c && pwd); g=$(basename $(dirname $c)); n=$(basename $c); sw=${SW[$g]}; key=${g}_$n
  SRC=dut.sv; [ -f $c/FILES ] && SRC=$(cat $c/FILES); GT=; [ -f $c/TOP ] && GT="--top $(cat $c/TOP)"
  ur=$(cd $c && timeout 120 $HOME/.local/bin/slang $SRC $GT --single-unit -q >/dev/null 2>&1; echo $?)
  p=$(bash $D/run1.sh $c $P p | cut -d' ' -f2-)
  l=$(bash $D/run1.sh $c $L l | cut -d' ' -f2-)
  bash $D/run1.sh $c $L o R11U418_OFF=1 >/dev/null
  bash $D/run1.sh $c $L s $sw=1 >/dev/null
  mp=$(md5sum < $O/$key/p/ours.uhdm 2>/dev/null | cut -c1-8); mo=$(md5sum < $O/$key/o/ours.uhdm 2>/dev/null | cut -c1-8); ms=$(md5sum < $O/$key/s/ours.uhdm 2>/dev/null | cut -c1-8)
  ro=$(cat $O/$key/o/rc); rs=$(cat $O/$key/s/rc); rp=$(cat $O/$key/p/rc)
  echo "$g/$n | slang rc=$ur | pristine $p | law $l | OFF $([ "$mo" = "$mp" ] && [ "$ro" = "$rp" ] && echo same || echo DIFF) | $sw $([ "$ms" = "$mp" ] && [ "$rs" = "$rp" ] && echo same || echo DIFF)"
done
