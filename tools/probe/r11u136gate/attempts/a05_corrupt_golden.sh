#!/bin/bash
# A5: a corrupted cache entry. (i) the golden truncated to 4096 bytes: uhdm-cmp
# aborts -> NOT_EQUAL, the gate FAILS (fails safe; the entry must be evicted by
# hand). (ii) a 0-byte golden: cache_load treats it as a miss and Surelog
# rebuilds it (first-write-wins keeps the 0-byte file, so every run rebuilds):
# the verdict is the clean one. Usage: <repo> <workdir>
set -u; R=$1; W=$2; G=$W.cache; C=r10earl59repro/a1_earl59
FA=(); grep -q "add_argument('--filter'" $R/scripts/compare_results.py && FA=(--filter "^$C\$")
for kind in trunc zero; do
  rm -rf $W $G; mkdir -p $G
  k=$(GOLDEN_CACHE=$G python3 -c "import os,sys; sys.path.insert(0,'$R/scripts'); import check_probe as c; print(os.path.basename(c.cache_dir('$C')))")
  cp -r $HOME/.cache/slang-uhdm-goldens/$k $G/$k
  if [ $kind = trunc ]; then truncate -s 4096 $G/$k/golden.uhdm; else : > $G/$k/golden.uhdm; fi
  echo "+ [$kind] GOLDEN_CACHE=<private> check_probe.py --filter '^$C\$'; compare_results.py ${FA[*]}"
  GOLDEN_CACHE=$G python3 $R/scripts/check_probe.py --jobs 1 --workdir $W --out $W.csv --filter "^$C\$" | grep -v strict
  python3 $R/scripts/compare_results.py $W.csv $R/results/golden_probe.csv "${FA[@]}" | grep -v '^ONLY-COMMITTED'; echo "GATE [$kind] rc=${PIPESTATUS[0]}"
done
