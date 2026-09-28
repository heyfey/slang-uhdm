#!/bin/bash
# r11u195: Earlgrey_0_1 default with each law that fires there switched off alone (the per-law attribution of its
# strict change).  usage: attrib_earlgrey.sh <out dir>   env: the pins (drivers/env.sh), binary $B/lawG.bin
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3; REPO=$(cd "$HERE/../../../.." && pwd); O=$1; mkdir -p $O
cd $REPO
for sw in NONE R11U195_PROCNETSEL_OFF R11U191_EARLCOL_OFF R11U191_EVALTS_OFF; do
  env ${sw/NONE/R11U195_UNUSED}=1 SLANG_UHDM=$B/lawG.bin python3 scripts/verify_golden.py --corpus surelog --mode default --jobs 1 \
    --filter '^Earlgrey_0_1$' --out $O/$sw.csv --workdir $O/wd_$sw > $O/$sw.log 2>&1
  echo "$sw $(grep '^Earlgrey_0_1,' $O/$sw.csv)"
done
