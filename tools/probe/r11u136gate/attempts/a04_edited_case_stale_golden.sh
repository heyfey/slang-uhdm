#!/bin/bash
# A4: a probe case edited in place is judged against the golden of its OLD
# text when the cache key is the case's path alone. The edit appends an empty
# module to r10earl59repro/a1_earl59 (EQUAL): against a golden Surelog builds
# from the edited text it is STRICT_EQUAL; against the old golden it is
# NOT_EQUAL (the verdict follows the stale entry, not the text). A private
# GOLDEN_CACHE is seeded with the shared entry the ORIGINAL text keys to.
# Expected: the verdict of the edited text (EQUAL, gate passes).
# Usage: <repo> <scratch>
set -u; R=$1; D=$2; G=$D.cache; C=r10earl59repro/a1_earl59
$(dirname $0)/mkfake.sh $R $D; rm -rf $G $D.wd; mkdir -p $G
k=$(GOLDEN_CACHE=$G python3 -c "import os,sys; sys.path.insert(0,'$D/scripts'); import check_probe as c; print(os.path.basename(c.cache_dir('$C')))")
cp -r $HOME/.cache/slang-uhdm-goldens/$k $G/$k; echo "seeded $k (the original text's key)"
printf 'module r11u136_extra;\nendmodule\n' >> $D/tests/probe/$C/dut.sv
k2=$(GOLDEN_CACHE=$G python3 -c "import os,sys; sys.path.insert(0,'$D/scripts'); import check_probe as c; print(os.path.basename(c.cache_dir('$C')))")
echo "edited text keys to $k2 ($([ $k = $k2 ] && echo 'the SAME entry: stale' || echo 'a new entry'))"
GOLDEN_CACHE=$G python3 $D/scripts/check_probe.py --jobs 3 --workdir $D.wd --out $D.csv --filter "^$C\$"; echo "check_probe rc=$?"
# the base compare_results.py has no --filter (it lists the rest as ONLY-COMMITTED)
FA=(); grep -q "add_argument('--filter'" $D/scripts/compare_results.py && FA=(--filter "^$C\$")
python3 $D/scripts/compare_results.py $D.csv $D/results/golden_probe.csv "${FA[@]}" | grep -v '^ONLY-COMMITTED'; rc=${PIPESTATUS[0]}
cat $D.csv
echo "GATE rc=$rc"
