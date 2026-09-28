#!/bin/bash
# r11u188: the whole-pass switch check.  offcheck.sh <law binary> <pristine sweep workdir> <outdir>
# runs every tests/probe case with R11U188_OFF=1 on the law binary (scripts/check_probe.py) and compares each
# database byte for byte with the pristine sweep's probe database; then every case dir of this pass
# (drivers/case.sh, pristine vs R11U188_OFF=1).  Prints same/differ counts and the differing names.
. "$(dirname "$0")/env.sh" || exit 3
B=$1; P=$2; O=$3; rm -rf $O; mkdir -p $O
cd "$R188_REPO" && R11U188_OFF=1 SLANG_UHDM=$B python3 scripts/check_probe.py --jobs 3 --workdir $O/probe --out $O/probe.csv > $O/probe.log 2>&1
same=0; diff=0
for f in $(cd $P/probe && ls *.uhdm); do
  if cmp -s $P/probe/$f $O/probe/$f; then same=$((same+1)); else diff=$((diff+1)); echo "probe differ $f"; fi
done
echo "probe same=$same differ=$diff"
same=0; diff=0
for d in $(find "$R188_REPO/tools/probe/r11u188repro/cases" -name 'dut.sv' -o -name 'dut.v' | xargs -n1 dirname | sort); do
  n=${d#$R188_REPO/tools/probe/r11u188repro/cases/}
  SLANG_UHDM=$R188_BIN/pris.bin "$(dirname "$0")/case.sh" $d $O/cases/pris/$n > /dev/null 2>&1
  R11U188_OFF=1 SLANG_UHDM=$B "$(dirname "$0")/case.sh" $d $O/cases/off/$n > /dev/null 2>&1
  if cmp -s $O/cases/pris/$n/ours.uhdm $O/cases/off/$n/ours.uhdm; then same=$((same+1)); else diff=$((diff+1)); echo "case differ $n"; fi
done
echo "cases same=$same differ=$diff"
