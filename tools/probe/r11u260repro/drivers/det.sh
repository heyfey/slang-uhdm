#!/bin/bash
# (r11u260: copied from r11u258repro/drivers)
# (r11u258: copied from r11u259repro/drivers)
# (r11u259: copied from r11u257repro/drivers)
# (r11u257: copied from r11u255repro/drivers)
# (r11u255: copied from r11u253repro/drivers)
# (r11u253: copied from r11u251repro/drivers; one job per draw: three concurrent processes)
# (r11u251: copied from r11u249repro/drivers)
# (r11u249: copied from r11u247repro/drivers)
# (r11u247: copied from r11u244repro/drivers)
# (r11u244: copied from r11u242repro/drivers)
# (r11u238 (from r11u236repro): copied from r11u232repro/drivers)
# (r11u244repro: copied from r11u218dec/drivers/det.sh) det.sh <binary> <tag>: three CONCURRENT harness runs of the binary on Earlgrey_0_1 and the five UVM rows (both
# modes; verify_golden.py --filter, the fenced names can never match the fixed list, checked below), then the md5 of
# every slang.uhdm per row-mode: one hash per row-mode = deterministic. Output under $S/det_<tag>_{1,2,3}.
[ -n "$FENCED" ] && [ -n "$S" ] || { echo "det.sh: source drivers/env.sh" >&2; exit 2; }
HERE=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$HERE/../../../.." && pwd)
BIN=$1; TAG=$2; T="Earlgrey_0_1 MiniAmiq SeqDriver SimpleUVM Scoreboard BuildUVMPkg"
for t in $T; do for f in $FENCED; do [ "$f" = "$t" ] && { echo "det.sh: fenced"; exit 2; }; done; done
FIL="^($(echo $T | tr ' ' '|'))$"
cd $REPO
for i in 1 2 3; do rm -rf $S/det_${TAG}_$i; SLANG_UHDM=$BIN python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 1 --filter "$FIL" --out $S/det_${TAG}_$i.csv --workdir $S/det_${TAG}_$i > $S/det_${TAG}_$i.log 2>&1 & done; wait
for m in default testflags; do for t in $T; do
  hs=$(for i in 1 2 3; do md5sum $S/det_${TAG}_$i/$m/$t-*/slang.uhdm 2>/dev/null | cut -c1-12; done | sort | uniq -c | tr '\n' ' ')
  echo "$TAG $t/$m $hs"
done; done
