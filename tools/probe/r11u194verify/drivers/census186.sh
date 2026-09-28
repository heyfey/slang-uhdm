#!/bin/bash
# (r11u194: adapted from r11u186repro/drivers/census.sh) census186.sh <workdir>: pass 186's firing census re-run on the
# HEAD binary in pass 186's integration state (passes 184 + r11v184, r11u185's refinement, r11u190's refinements,
# passes 187, 188 + v11u188 off = a3a62624 + pass 186) with R11U183_TRACE / R11U186_TRACE: every corpus row-mode but
# the four fenced tests (--filter built from $FENCED, read by env.sh from canaudit.sh; fail closed) and every
# tests/probe case.  The result is compared with r11u186repro/evidence/predicted_movers_final.tsv (process check).
set -eu
source "$(dirname "$0")/env.sh"
W=$1; rm -rf $W; mkdir -p $W/tr
NEGFENCE="^(?!($(echo $FENCED | tr ' ' '|'))$)"
w=$R194_BIN/s186tr.sh
printf '#!/bin/bash\nexec env R11U184_OFF=1 R11V184_OFF=1 R11V185_OFF=1 R11V190_OFF=1 R11U187_OFF=1 R11U188_OFF=1 R11V188_OFF=1 R11U183_TRACE=%s/tr R11U186_TRACE=%s/tr %s/law.bin "$@"\n' $W $W $R194_BIN > $w; chmod 555 $w
export SLANG_UHDM=$w
cd $R194_ROOT
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$NEGFENCE" --out $W/sl.csv --workdir $W/surelog > $W/sl.log 2>&1
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter "$NEGFENCE" --out $W/u2r.csv --workdir $W/uhdm2rtlil > $W/u2r.log 2>&1
python3 scripts/check_probe.py --jobs 3 --workdir $W/probe --out $W/probe.csv > $W/probe.log 2>&1 || true
echo CENSUS_DONE
