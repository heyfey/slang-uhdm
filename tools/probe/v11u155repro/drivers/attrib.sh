#!/bin/bash
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil STRICT_CMP=/tmp/v11u155_bin/uhdm-strictcmp
export SLANG_UHDM=/tmp/v11u155_bin/law.bin
O=/tmp/v11u155_att; mkdir -p $O
SMALL='GenForIfaceLocalparamBound|GenForIfaceLocalparamNestedGen|IfGenTypeBinding|ImplicitArg|OneNetModPort|OneNetModPortGeneric|SimpleConstraint|UnpackPort'
BIG='Earlgrey_0_1|Rggen|YosysBigSimEllip'
U2='^(const_cast_signext|genscope_module_ctx_reset|iface_sig_in_child_port|OneNetModport|PatternStruct|union_param_repro)$'
cd /tmp/wt_v11u155pris
for sw in R11U155_OFF R11U155_PRGINITEND_OFF R11U155_IMPLARGDIM_OFF R11U155_NAARRNET_OFF R11U155_UNITUNIONARG_OFF R11U155_UNITSTRUCTARG_OFF R11U155_PSELNAME_OFF R11U155_NDAFOLDLOC_OFF R11U155_PVLEFTOP_OFF R11U155_TDSTRETCHHDR_OFF R11U155_MODAGGARG_OFF R11U155_DIRLESSNAME_OFF R11U155_IFSIGCHILD_OFF; do
  case $sw in R11U155_OFF|R11U155_PSELNAME_OFF|R11U155_IFSIGCHILD_OFF) SL="^($SMALL|$BIG)\$";; *) SL="^($SMALL)\$";; esac
  ( export $sw=1
    python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$SL" --out $O/sl_$sw.csv --workdir $O/wd_$sw/surelog > $O/sl_$sw.log 2>&1
    python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter "$U2" --out $O/u2_$sw.csv --workdir $O/wd_$sw/uhdm2rtlil > $O/u2_$sw.log 2>&1 )
  for c in surelog uhdm2rtlil; do
    (cd $O/wd_$sw/$c && find . -name slang.uhdm | sort) | while read p; do
      if cmp -s $O/wd_$sw/$c/$p /tmp/v11u155_swP/$c/$p; then r=PRISTINE; elif cmp -s $O/wd_$sw/$c/$p /tmp/v11u155_swL/$c/$p; then r=LAW; else r=OTHER; fi
      echo "$sw $c ${p%/slang.uhdm} $r"
    done
  done
done > $O/attrib.txt
echo done >> $O/attrib.txt
