#!/bin/bash
# r11u421 predict.sh: law binary with R11U421_TRACE on the candidate surelog rows (both modes), all uhdm2rtlil rows and all probe cases
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export SLANG_UHDM=/tmp/r11u421_law.bin STRICT_CMP=/tmp/r11u421_bin/strictcmp
for v in SURELOG UHDM_CMP UHDM_DUMP SLANG_UHDM; do [ -x "${!v}" ] || { echo "no $v"; exit 9; }; done
/tmp/r11u421_bin/quiet.sh || exit 8
W=/tmp/r11u421_pred; rm -rf $W; mkdir -p $W/tr $W/sl $W/u2r $W/pr
export R11U421_TRACE=$W/tr
F='^(BitsHierPath|BitsInGenBlock|BitsLogic|BitsOp|BlackBePipeInt|Ariane|Ariane2024|ArianeElab|ArianeElab2|AzadiRTL|BitComplex|BitsArray|BlackParrot|BlackParrotComplex|BlackParrotConf|BlackParrotMuteErrors|BlackParrotParam|BlackParrotSkipParam|BlackParrotStructParam|Earlgrey|Earlgrey_0_1|Earlgrey_nexysvideo|EarlgreyPackParam|Earlgrey_Verilator_0_1|Earlgrey_Verilator_01_05_21|ExpectStmt|HierPathUnpacked|HierPathUnpackedInPacked|Ibex|IbexGoogle|IncompFunc|IncompTitan|InterpElab1|NyuziProcessor|Opentitan|PackageEval|PackDataType|ParamComplexVerilator|Rggen|Rsd|SplitFile|TestFileSplit|Tnoc|TNocBadType|Verilator)$'
cd /tmp/wt_r11u421
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --out $W/u2r.csv --workdir $W/u2r > $W/u2r.log 2>&1
python3 scripts/check_probe.py --jobs 3 --out $W/probe.csv --workdir $W/pr > $W/probe.log 2>&1
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --out $W/sl.csv --workdir $W/sl --filter "$F" > $W/sl.log 2>&1
echo done
