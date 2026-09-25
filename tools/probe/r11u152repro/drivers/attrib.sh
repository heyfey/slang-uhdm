#!/bin/bash
# attrib.sh <outdir>: the switch attribution of every corpus row-mode the law sweep moved.
# For each r11u152 switch, verify_golden.py re-runs the moved tests (both modes) with the law binary
# and that ONE switch set; a row whose verdict returns to its pristine value names the switch's law.
# Fail-closed on $FENCED (the moved lists below never hold a fenced name; the check refuses to run
# without the variable).
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "attrib.sh: export FENCED (four names) first" >&2; exit 1; }
O=$1; mkdir -p $O
SL='^(ClassParamAsParam|CrossFunc|DelayAssign|GenCase|GenCaseStmt|PackageMemberTypespec|PackedEnumPort|TypeParamElab|UnsupportedTypespecRange|ClassTypeParam|GenerateUnnamed|ParamTypespec2)$'
U2='^(FileLevelUnionWithMultirange|LocalParamInNestedForLoops|StructArrayParameterInitializedByPatternPassedAsPort|VarPassedTo2Submodules|packed_array_struct_port_sel|struct_member_cfg_width|type_param_packed_dim|NestedStructArrayParameterInitializedByPatternPassedAsPort|gen_scope_typaram|type_param_override_elem_sel|ibex_alu|ibex_branch_predict|ibex_compressed_decoder|ibex_decoder|ibex_icache|ibex_multdiv_fast|ibex_multdiv_slow|ibex_pmp|ibex_tracer|ibex_wb_stage)$'
for f in $FENCED; do echo "$SL$U2" | grep -qw "$f" && { echo "fenced name in list" >&2; exit 1; }; done
cd $(dirname $0)/../../../..
export SLANG_UHDM=${LAW:-/tmp/r11u152_bin/law2.bin}
for sw in NONE R11U152_C3_OFF R11U152_GENLPOPTS_OFF R11U152_FOLDCHAIN_OFF R11U152_TPELEMPAT_OFF \
          R11U152_PKGELEMPAT_OFF R11U152_ELEMALIAS_OFF R11U152_TPOVRSTRUCT_OFF R11U152_GENCASE_OFF \
          R11U152_DLYREAL_OFF R11U152_CGINITEND_OFF R11U152_CLSVARINIT_OFF R11U152_CLSNESTNAME_OFF \
          R11U152_CLSPANOFILE_OFF R11U152_PKGLEAFLOC_OFF; do
  ( [ $sw = NONE ] || export $sw=1
    python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$SL" \
        --out $O/sl_$sw.csv --workdir $O/wd_sl_$sw > $O/sl_$sw.log 2>&1
    python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter "$U2" \
        --out $O/u2_$sw.csv --workdir $O/wd_u2_$sw > $O/u2_$sw.log 2>&1 )
  echo "$sw done"
done
