#!/bin/bash
# per-patch attribution (r11u211): probe (all 4087) + the corpus rows of the four tests the law205 census predicted as
# movers and the five UVM rows (the coin / orphan controls), none slang-fenced (checked against $FENCED below, fail
# closed), with lawA205 (law_exprstmt alone) and lawB205 (law_typeemit minus its superseded first law, alone).
. /tmp/wt_r11u211/tools/probe/r11u211map/drivers/env.sh
T='Earlgrey_0_1 InterfArrayBind Rggen UnitElabBlock MiniAmiq SeqDriver SimpleUVM Scoreboard BuildUVMPkg'
for t in $T; do echo $t | grep -Pq "$FENCERE" && { echo "fenced name in the filter: refusing"; exit 3; }; done
F="^($(echo $T | tr ' ' '|'))\$"
cd /tmp/wt_r11u211
for x in A B; do
  export SLANG_UHDM=/tmp/r11u211_bin/slang-uhdm.law${x}205; W=/tmp/r11u211_at$x; mkdir -p $W
  python3 scripts/check_probe.py --jobs 3 --out $W/probe.csv --workdir $W/probe > $W/probe.log 2>&1
  python3 scripts/compare_results.py $W/probe.csv results/golden_probe.csv > $W/probe.cmp 2>&1
  for c in surelog uhdm2rtlil; do
    python3 scripts/verify_golden.py --corpus $c --mode both --jobs 3 --filter "$F" --out $W/$c.csv --workdir $W/$c > $W/$c.log 2>&1
    python3 scripts/compare_results.py $W/$c.csv results/golden_$c.csv --filter "$F" > $W/$c.cmp 2>&1
  done
done
echo ATTR_DONE
