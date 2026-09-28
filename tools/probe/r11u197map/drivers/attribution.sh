#!/bin/bash
# per-patch attribution: probe (all 4087) + the corpus rows of the 123 law191 movers' tests, lawA (law_exprstmt alone)
# and lawB (law_typeemit alone). None of the listed tests is slang-fenced (checked against $FENCED when written).
. /tmp/wt_r11u197/tools/probe/r11u197map/drivers/env.sh
cd /tmp/wt_r11u197
F='^(ApbSlave|AssignmentPatternInAssignmentPattern|AssignSubs|BitSelectOfParameterPassedToSubmodule|BitSelectOfParameterPassedToSubmoduleInGenFor|BitSelectOfParameterPassedToSubmoduleInGenForOfSubmodule|BlackBePipeInt|BuildUVMPkg|ComplexParamOverload|ComplexParamOverload2|const_cast_signext|ConstPort|cs_registers|Earlgrey_0_1|EnumConcat|FuncCase|GenIfInside|GenScopeHierPath|hier_path|HierPathOverride|ibex_alu|ibex_branch_predict|ibex_compressed_decoder|ibex_decoder|ibex_icache|ibex_multdiv_fast|ibex_multdiv_slow|ibex_pmp|ibex_tracer|ibex_wb_stage|ImportBinding|ImportedEnumCast|IndexedSelectHex|InsideOp|jeras_union|MiniAmiq|MultiConcatValueSize|OneImport|PackImport|ParamByValue|ParamCast|ParamConst|ParamElabMulti|ParameterInitializedInSubModuleOfTopOf5LevelHierarchy|ParameterInitializedInTopOf5LevelHierarchy|ParameterInitializedInTopOf5LevelHierarchyWithUnusedParamInTheMiddle|ParameterInitializedInTopOf5LevelHierarchyWithUnusedParamOfDifferentTypeInTheMiddle|ParameterPassedTo3TimesNestedSubmodule|ParameterPassedToSubmoduleInGenscopeOfSubmodule|ParameterPassedToSubmoduleOfSubmodule|rp32_r5p_alu|rp32_r5p_bru|rp32_r5p_mdu|rp32_r5p_wbu|rsp_gen_minimal|Scoreboard|Scr1SvTests|SeqDriver|SimpleUVM|SubmoduleInGenScopeWithGenScopeParametrizedByParameterFromTopModule|UnionCast)$'
for x in A B; do
  export SLANG_UHDM=/tmp/r11u197_bin/slang-uhdm.law$x; W=/tmp/r11u197_at$x; mkdir -p $W
  python3 scripts/check_probe.py --jobs 2 --out $W/probe.csv --workdir $W/probe > $W/probe.log 2>&1
  python3 scripts/compare_results.py $W/probe.csv results/golden_probe.csv > $W/probe.cmp 2>&1
  for c in surelog uhdm2rtlil; do
    python3 scripts/verify_golden.py --corpus $c --mode both --jobs 2 --filter "$F" --out $W/$c.csv --workdir $W/$c > $W/$c.log 2>&1
    python3 scripts/compare_results.py $W/$c.csv results/golden_$c.csv --filter "$F" > $W/$c.cmp 2>&1
  done
done
echo ATTR_DONE
