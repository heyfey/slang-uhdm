#!/bin/bash
# three113.sh <binary> <tag>: run the three r11u113 target rows (uhdm2rtlil, both modes) and
# uhdm-cmp each (LHS golden).  Own workdir ${THREEWD}/<tag>; refuses to reuse one.
B=${1:?binary}; T=${2:?tag}; W=${THREEWD:-/tmp/r11u113_three}/$T; [ -e "$W" ] && { echo "refusing: $W exists"; exit 3; }; mkdir -p "$W"
cd "${REPO:-/home/heyfey/git-repos/slang-uhdm}"
export SLANG_UHDM=$B
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter '^(arb_idx_cast|ibex_pmp|ibex_icache)$' --out $W/u2r.csv --workdir $W/u2r > $W/u2r.log 2>&1
grep -h -v '^name' $W/u2r.csv
find $W -name cmds.txt | xargs grep -h '^slang:' | awk '{print "BIN", $2}' | sort | uniq -c
for d in $(find $W -name slang.uhdm -printf '%h\n' | sort); do g=$(grep -o 'cache hit [^)]*' $d/cmds.txt | awk '{print $3}')/golden.uhdm; ~/git-repos/UHDM/build/bin/uhdm-cmp $g $d/slang.uhdm > $d/cmp.txt 2>&1; echo "$(echo $d | sed "s#$W/##") lines=$(wc -l < $d/cmp.txt) heads=$(grep -c '^LHS:' $d/cmp.txt; true)"; done
