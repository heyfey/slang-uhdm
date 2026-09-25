#!/bin/bash
# attrib.sh <outdir>: single-switch byte attribution of every corpus mover of the law sweep.
# For R11U155_OFF and each r11u155 switch, verify_golden.py re-runs the moved tests (both modes) with
# the law binary and that ONE switch set; bytecmp against the pristine sweep names the law whose
# switch returns a mover to pristine bytes.  Fail-closed on $FENCED (word match against the lists).
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "attrib.sh: export FENCED (four names) first" >&2; exit 1; }
O=$1; mkdir -p $O
SL='^(Earlgrey_0_1|GenForIfaceLocalparamBound|GenForIfaceLocalparamNestedGen|IfGenTypeBinding|ImplicitArg|MiniAmiq|OneNetModPort|OneNetModPortGeneric|Rggen|SeqDriver|SimpleConstraint|SimpleUVM|UnpackPort|YosysBigSimEllip)$'
U2='^(const_cast_signext|genscope_module_ctx_reset|iface_sig_in_child_port|OneNetModport|PatternStruct|union_param_repro)$'
for f in $FENCED; do echo "$SL$U2" | grep -qw "$f" && { echo "fenced name in list" >&2; exit 1; }; done
cd $(dirname $0)/../../../..
export SLANG_UHDM=${LAW:-/tmp/r11u155_bin/law2.bin}
for sw in R11U155_OFF R11U155_PRGINITEND_OFF R11U155_IMPLARGDIM_OFF R11U155_NAARRNET_OFF \
          R11U155_UNITUNIONARG_OFF R11U155_UNITSTRUCTARG_OFF R11U155_PSELNAME_OFF R11U155_NDAFOLDLOC_OFF \
          R11U155_PVLEFTOP_OFF R11U155_TDSTRETCHHDR_OFF R11U155_MODAGGARG_OFF R11U155_DIRLESSNAME_OFF \
          R11U155_IFSIGCHILD_OFF; do
  ( export $sw=1
    python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$SL" \
        --out $O/sl_$sw.csv --workdir $O/wd_$sw/surelog > $O/sl_$sw.log 2>&1
    python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter "$U2" \
        --out $O/u2_$sw.csv --workdir $O/wd_$sw/uhdm2rtlil > $O/u2_$sw.log 2>&1 )
  for c in surelog uhdm2rtlil; do
    (cd $O/wd_$sw/$c && find . -name slang.uhdm) | while read p; do
      cmp -s $O/wd_$sw/$c/$p ${PRIS:-/tmp/r11u155_swP}/$c/$p && echo "$sw $c ${p%/slang.uhdm} PRISTINE" ||
        { cmp -s $O/wd_$sw/$c/$p ${LAWWD:-/tmp/r11u155_swL}/$c/$p && echo "$sw $c ${p%/slang.uhdm} LAW" || echo "$sw $c ${p%/slang.uhdm} OTHER"; }
    done
  done
done
