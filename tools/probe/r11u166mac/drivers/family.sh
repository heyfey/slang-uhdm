#!/bin/bash
# family.sh <binary> <workdir>  — the family's corpus rows (both modes) with one binary; prints name,mode,status,strict.
# The filters list the family by name; FENCED must be set and no fenced name may occur in them (checked).
set -u
: "${FENCED:?}"
bin=$1; wd=$2
U2R='^(ibex_.*)$'
SL='^(MacroArgMismatch|YosysMarlann|CovMacro|Rggen|SimpleUVM|SeqDriver|MiniAmiq|Scoreboard|BuildUVMPkg|Earlgrey_0_1|Scr1SvTests|YosysOldOr|YosysOldSpi|ApbSlave)$'
for f in $FENCED; do echo "$U2R $SL" | grep -qw "$f" && { echo "REFUSE: fenced name in filter"; exit 3; }; done
R=$(cd "$(dirname "$0")/../../../.." && pwd)
mkdir -p "$wd"
export SLANG_UHDM=$bin
python3 "$R/scripts/verify_golden.py" --corpus uhdm2rtlil --mode both --jobs 3 --filter "$U2R" --out "$wd/u2r.csv" --workdir "$wd/u2r" > "$wd/u2r.log" 2>&1
python3 "$R/scripts/verify_golden.py" --corpus surelog --mode both --jobs 3 --filter "$SL" --out "$wd/sl.csv" --workdir "$wd/sl" > "$wd/sl.log" 2>&1
tail -n +2 "$wd/u2r.csv" | cut -d, -f1,2,3,6; tail -n +2 "$wd/sl.csv" | cut -d, -f1,2,3,6
