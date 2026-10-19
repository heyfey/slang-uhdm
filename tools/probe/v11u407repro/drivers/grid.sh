#!/bin/bash
# grid.sh <pristine bin> <law bin> <scratch dir> [verified bin] [case dir root]
# Per case dir: golden (pinned Surelog -parse -nobuiltin -nocache -sv dut.sv),
# each binary (dut.sv --single-unit --nobuiltin) with its exit code, uhdm-cmp
# line count, uhdm-strictcmp verdict and the normalised dump distance to
# golden (diff lines); then the case's own law switch and R11U407_OFF on the
# law binary must give pristine's bytes and exit code.
H=$(cd $(dirname $0)/.. && pwd)
SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
SC=${STRICT_CMP:-/tmp/v11u407_bin/strictcmp}
P=$1; L=$2; W=$3; V=${4:-}; ROOT=${5:-$H/cases}; mkdir -p $W
declare -A SW=([assertLocalVarImplicitNet407]=R11U407_ASSERTLOCALNET_OFF [seqEventCtrlRefDecl407]=R11U407_SEQEVREF_OFF [tpCastOverrideKeepsDefault407]=R11U407_TPCASTDEFAULT_OFF [pkgRetEnumOperandFold407]=R11U407_RETENUMFOLD_OFF [pkgRetBitSelParamFold407]=R11U407_RETBSPARAM_OFF [typedParamXzLitSize407]=R11U407_XZLITSIZE_OFF)
norm() { $DUMP $1 2>&1 | tail -n +2 | sed -E 's/id:[0-9]+,? ?//; s/, file:[^,]*//'; }
verdict() { [ -s $2 ] || { echo "NO_DB"; return; }
  local n=$($CMP $1 $2 2>&1 | wc -l); local d=$(diff <(norm $1) <(norm $2) | grep -c '^[<>]')
  echo "cmp=$n dist=$d $($SC $1 $2 2>&1 | tail -1)"; }
n=0; sw=0; off=0
while read -r d <&3; do
  c=$(dirname $d); g=$(basename $(dirname $c)); k=$g/$(basename $c); key=$(echo $k | tr / _)
  law=$(head -1 $d | sed -E 's/^\/\/ § //; s/ .*//')
  rm -rf $W/g_$key; mkdir -p $W/g_$key; ( cd $c && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $W/g_$key >/dev/null 2>&1 </dev/null )
  G=$W/g_$key/slpp_all/surelog.uhdm
  line="$k"
  for b in P L V; do bin=${!b}; [ -n "$bin" ] || continue; rm -f $W/$key.$b.uhdm
    ( cd $c && $bin dut.sv --single-unit --nobuiltin -o $W/$key.$b.uhdm >/dev/null 2>&1 </dev/null ); echo $? > $W/$key.$b.rc
    line="$line | $b rc=$(cat $W/$key.$b.rc) $(verdict $G $W/$key.$b.uhdm)"; done
  echo "$line"
  s=${SW[$law]:-R11U407_NONE_OFF}
  rm -f $W/$key.S.uhdm; ( cd $c && env $s=1 $L dut.sv --single-unit --nobuiltin -o $W/$key.S.uhdm >/dev/null 2>&1 </dev/null ); echo $? > $W/$key.S.rc
  if { cmp -s $W/$key.P.uhdm $W/$key.S.uhdm || [ ! -e $W/$key.P.uhdm -a ! -e $W/$key.S.uhdm ]; } && cmp -s $W/$key.P.rc $W/$key.S.rc; then sw=$((sw+1)); else echo "  OWN-SWITCH-MOVES $k [$s]"; fi
  rm -f $W/$key.O.uhdm; ( cd $c && R11U407_OFF=1 $L dut.sv --single-unit --nobuiltin -o $W/$key.O.uhdm >/dev/null 2>&1 </dev/null ); echo $? > $W/$key.O.rc
  if { cmp -s $W/$key.P.uhdm $W/$key.O.uhdm || [ ! -e $W/$key.P.uhdm -a ! -e $W/$key.O.uhdm ]; } && cmp -s $W/$key.P.rc $W/$key.O.rc; then off=$((off+1)); else echo "  PASS-OFF-MOVES $k"; fi
  n=$((n+1))
done 3< <(find $ROOT -name dut.sv | sort)
echo "cases=$n own-switch-restores-pristine=$sw R11U407_OFF-restores-pristine=$off"
