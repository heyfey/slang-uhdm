#!/bin/bash
# per-patch attribution (r11u203): probe (all 4087) + the corpus rows of the 62 tests the law200 census predicted as movers
# (none slang-fenced: checked against $FENCED when written), lawA (law_exprstmt alone) and lawB (law_typeemit alone).
. /tmp/wt_r11u203/tools/probe/r11u203map/drivers/env.sh
cd /tmp/wt_r11u203
F='^(ApbSlave|ArrayExprFuncArg|AssignBitsCallToSubmoduleParameter|BasicOh|BitsArray|BuildUVMPkg|CastToSumWithParameterIn2InstancesOfSubmodule|CastToSumWithParameterInSubmodule|cfg_func_width_loop|DollarBits|Earlgrey_0_1|FuncCase|FuncIoTypespec|FuncStructVal|generate_test|GenNet|genscope_module_ctx_reset|gen_scope_numports|iface_array_modport_drive|iface_param_2level|iface_param_port_width|iface_struct_field_param_width|int_types|jeras_tcb_gpio|jeras_union|MiniAmiq|mriscv_bind_sva|multiplier|OneNetRange|OutputSizeWithParameterOfInstanceInitializedByStructMember|param_array_wildcard|ParameterOfSizeOfParametrizedPortInSubmodule|param_fill_default_paramod|ParamMultiConcat|param_name_collision_typeparam|param_type_logic_width|ReplicationPassedToInstance|Rggen|rp32_r5p_alu|rp32_r5p_bru|rp32_r5p_mdu|rp32_r5p_mouse_soc_simple_top|rp32_r5p_wbu|Scoreboard|Scr1SvTests|SeqDriver|simple_hierarchy|simple_interface|SimpleUVM|size_cast_param|struct_param_func_config|SVSwitch|UnionCast|UnitElabBlock|YosysBigSimEllip|YosysBigSimReed|YosysBigSimSoft|YosysOldOpen|YosysOldOr|YosysOldSimpleSpi|YosysOldSpi|YosysRiscv)$'
for x in A B; do
  export SLANG_UHDM=/tmp/r11u203_bin/slang-uhdm.law$x; W=/tmp/r11u203_at$x; mkdir -p $W
  python3 scripts/check_probe.py --jobs 3 --out $W/probe.csv --workdir $W/probe > $W/probe.log 2>&1
  python3 scripts/compare_results.py $W/probe.csv results/golden_probe.csv > $W/probe.cmp 2>&1
  for c in surelog uhdm2rtlil; do
    python3 scripts/verify_golden.py --corpus $c --mode both --jobs 3 --filter "$F" --out $W/$c.csv --workdir $W/$c > $W/$c.log 2>&1
    python3 scripts/compare_results.py $W/$c.csv results/golden_$c.csv --filter "$F" > $W/$c.cmp 2>&1
  done
done
echo ATTR_DONE
