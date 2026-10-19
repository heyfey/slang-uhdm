#!/bin/bash
# grid.sh <pristine bin> <law bin> <scratch dir> [golden dir]
# v11u405 (adversarial verification of r11u405).  Per case dir: golden
# (Surelog v1.87 -parse -nobuiltin -nocache -sv dut.sv, cached in the golden
# dir), both binaries (dut.sv --single-unit --nobuiltin) with exit codes,
# uhdm-cmp line count, uhdm-strictcmp verdict and the normalised uhdm-dump
# distance to golden (diff lines); then the group's own switch(es) and
# R11U405_OFF on the law binary must give pristine's bytes and exit code.
H=$(cd $(dirname $0)/.. && pwd)
export SURELOG=${SURELOG:-/home/heyfey/git-repos/Surelog/build/bin/surelog}
CMPT=${UHDM_CMP:-/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp}
DUMP=${UHDM_DUMP:-/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump}
SC=${STRICT_CMP:-/home/heyfey/git-repos/slang-uhdm/build/uhdm-strictcmp}
P=$1; L=$2; W=$3; GD=${4:-$W/gold}; mkdir -p $W $GD
[ -x "$P" ] && [ -x "$L" ] && [ -x "$SC" ] && [ -x "$CMPT" ] && [ -x "$DUMP" ] || { echo "tool missing"; exit 2; }
declare -A SW=([VS]="R11U405_UNDEFCASTTS_OFF R11U405_CASTGENFENCE_OFF R11U405_CASTPARENCOMP_OFF" [VK]=R11U405_BITSPARAM_OFF [VZ]="R11U405_IMPUNBASED_OFF R11U405_IMPUNBASEDREAD_OFF" [VA]=R11U405_UNPDIMARITH_OFF [VH]=R11U405_HSWLOCAL_OFF [VR]=R11U405_REPPATNEST_OFF [VD]=R11U405_DISABLETGT_OFF [VT]=R11U405_TYPENAMEKW_OFF [VB]=R11U405_BLKPARAM_OFF [VC]=R11U405_IFTDCAST_OFF [VE]=R11U405_TPCASTEARLY_OFF [VI]=R11U405_IMPNETNAME_OFF [VP]=R11U405_IMPLPORTLAST_OFF [VM]=R11U405_HSMACROBND_OFF [VU]=R11U405_UNBOUNDEDPARAM_OFF)
norm() { $DUMP $1 2>/dev/null | sed 1d | sed -E 's#/[^ ,]*/(dut\.sv)#\1#g' ; }
dist() { diff <(norm $1) <(norm $2) | grep -c '^[<>]'; }
verdict() { local n=$($CMPT $1 $2 2>&1 | wc -l); echo "cmp=$n $($SC $1 $2 2>&1 | tail -1) dist=$(dist $1 $2)"; }
n=0; sw=0; off=0
while read -r d <&3; do
  c=$(dirname $d); g=$(basename $(dirname $c)); k=$g/$(basename $c); key=$(echo $k | tr / _)
  if [ ! -f $GD/$key/slpp_all/surelog.uhdm ]; then mkdir -p $GD/$key; ( cd $c && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $GD/$key >$GD/$key/log 2>&1 </dev/null ); fi
  G=$GD/$key/slpp_all/surelog.uhdm
  for b in P L; do bin=${!b}; rm -f $W/$key.$b.uhdm
    ( cd $c && $bin dut.sv --single-unit --nobuiltin -o $W/$key.$b.uhdm >$W/$key.$b.log 2>&1 </dev/null ); echo $? > $W/$key.$b.rc; done
  if cmp -s $W/$key.P.uhdm $W/$key.L.uhdm; then same=bytes-same; else same=bytes-moved; fi
  echo "$k pristine rc=$(cat $W/$key.P.rc) $(verdict $G $W/$key.P.uhdm) | law rc=$(cat $W/$key.L.rc) $(verdict $G $W/$key.L.uhdm) | $same"
  e=""; for s in ${SW[$g]}; do e="$e $s=1"; done
  rm -f $W/$key.S.uhdm; ( cd $c && env $e $L dut.sv --single-unit --nobuiltin -o $W/$key.S.uhdm >/dev/null 2>&1 </dev/null ); echo $? > $W/$key.S.rc
  if cmp -s $W/$key.P.uhdm $W/$key.S.uhdm && cmp -s $W/$key.P.rc $W/$key.S.rc; then sw=$((sw+1)); else echo "  OWN-SWITCH-MOVES $k [$e]"; fi
  rm -f $W/$key.O.uhdm; ( cd $c && R11U405_OFF=1 $L dut.sv --single-unit --nobuiltin -o $W/$key.O.uhdm >/dev/null 2>&1 </dev/null ); echo $? > $W/$key.O.rc
  if cmp -s $W/$key.P.uhdm $W/$key.O.uhdm && cmp -s $W/$key.P.rc $W/$key.O.rc; then off=$((off+1)); else echo "  PASS-OFF-MOVES $k"; fi
  n=$((n+1))
done 3< <(find $H/cases -name dut.sv | sort | grep -E "${FILTER:-.}")
echo "cases=$n own-switch-restores-pristine=$sw R11U405_OFF-restores-pristine=$off"
