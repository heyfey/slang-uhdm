#!/bin/bash
# predict.sh: traced targeted runs of the scan's candidate rows on the law binary (before the sweep)
B=/tmp/r11u431_law9/slang-uhdm; W=/tmp/r11u431_pred; T=/tmp/r11u431_pred/trace
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil SLANG_UHDM=$B R11U431_TRACE=$T
for v in SURELOG UHDM_CMP UHDM_DUMP SLANG_UHDM; do [ -x "${!v}" ] || { echo "missing $v"; exit 2; }; done
S=/tmp/r11u431_scr/scan
mkdir -p $W $T
cd /tmp/wt_r11u431
SLR="^($(paste -sd'|' $S/sl_final.txt))\$"
U2R="^($(paste -sd'|' $S/u2r_final.txt))\$"
PR="^($(sed 's/[.]/\\./g' $S/probe_keys.txt | paste -sd'|'))\$"
python3 scripts/check_probe.py --jobs 3 --out $W/probe.csv --workdir $W/probe --filter "$PR" > $W/probe.log 2>&1; echo "probe rc=$?"
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --out $W/sl.csv --workdir $W/sl --filter "$SLR" > $W/sl.log 2>&1; echo "sl rc=$?"
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --out $W/u2r.csv --workdir $W/u2r --filter "$U2R" > $W/u2r.log 2>&1; echo "u2r rc=$?"
python3 scripts/downstream_uhdm2rtlil.py --jobs 3 --workdir $W/ds --out $W/ds.csv --filter "$U2R" > $W/ds.log 2>&1; echo "ds rc=$?"
echo PREDDONE
