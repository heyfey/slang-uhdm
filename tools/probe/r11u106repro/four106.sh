#!/bin/bash
# run the four target rows with binary $1 under tag dir $2; print cmp lines/heads per arm
B=${1:?binary}; T=${2:?tag}; W=${FOURWD:-/tmp/r11u106_four}_$T; [ -e "$W" ] && { echo "refusing: $W exists"; exit 3; }; mkdir -p "$W"
cd "$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
export SLANG_UHDM=$B
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter '^(StructParamFieldRange|StructParamFuncBodyFieldCompare)$' --out $W/sl.csv --workdir $W/sl > $W/sl.log 2>&1
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter '^(cva6_struct_param_field|mem_packed_2d_byte_write)$' --out $W/u2r.csv --workdir $W/u2r > $W/u2r.log 2>&1
grep -h -v '^name' $W/sl.csv $W/u2r.csv
find $W -name cmds.txt | xargs grep -h '^slang:' | awk '{print "BIN", $2}' | sort | uniq -c
for d in $(find $W -name slang.uhdm -printf '%h\n' | sort); do g=$(grep -o 'cache hit [^)]*' $d/cmds.txt | awk '{print $3}')/golden.uhdm; ~/git-repos/UHDM/build/bin/uhdm-cmp $g $d/slang.uhdm > $d/cmp.txt 2>&1; echo "$(echo $d | sed "s#$W/##") lines=$(wc -l < $d/cmp.txt) heads=$(grep -c '^LHS:' $d/cmp.txt)"; done
