#!/bin/bash
# per-patch attribution: probe (all 4087) + the corpus movers, lawA (law_exprstmt alone) and lawB (law_typeemit alone)
. /tmp/wt_r11u189/tools/probe/r11u189map/drivers/env.sh
cd /tmp/wt_r11u189
F='^(ApbSlave|ArrayMethodIterator|BuildUVMPkg|Earlgrey_0_1|LargeValue2Struct|MiniAmiq|Rggen|SVSwitch|Scoreboard|SeqDriver|SimpleUVM|StructUnsizedVal|UnionCast|jeras_union|ParameterFromPkgInNestedModule|ParameterFromPkgOnParameterPortList|rp32_r5p_alu|rp32_r5p_bru|rp32_r5p_mdu|rp32_r5p_wbu|const_cast_signext|struct_param_func_config)$'
for x in A B; do
  export SLANG_UHDM=/tmp/r11u189_bin/slang-uhdm.law$x; W=/tmp/r11u189_at$x; mkdir -p $W
  python3 scripts/check_probe.py --jobs 3 --out $W/probe.csv --workdir $W/probe > $W/probe.log 2>&1
  python3 scripts/compare_results.py $W/probe.csv results/golden_probe.csv > $W/probe.cmp 2>&1
  for c in surelog uhdm2rtlil; do
    python3 scripts/verify_golden.py --corpus $c --mode both --jobs 3 --filter "$F" --out $W/$c.csv --workdir $W/$c > $W/$c.log 2>&1
    python3 scripts/compare_results.py $W/$c.csv results/golden_$c.csv --filter "$F" > $W/$c.cmp 2>&1
  done
done
echo ATTR_DONE
