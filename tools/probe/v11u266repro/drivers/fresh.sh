#!/bin/bash
# v11u266 fresh.sh <out-prefix>: the adversarial grid of cases/VA and cases/VS on the frozen binaries, with the
# implementer's drivers (tools/probe/r11u266repro/drivers: env.sh, grid.sh, gridsum.py, awayall.sh, awaychain.py,
# dscases.py). Paths resolve from this checkout; export B (pristine, law, uhdm-strictcmp, strictcmp_x) and S.
# The configurations: P, L, OFF (R11U266_OFF) and each law switch alone. Fail-closed on $FENCED through env.sh.
H=$(cd "$(dirname "$0")/.." && pwd); D=$H/../r11u266repro/drivers
. "$D/env.sh" || exit 2
out=$1; [ -n "$out" ] || { echo "usage: fresh.sh <out-prefix>" >&2; exit 2; }
export R266_SW="R11U266_PKGTDLISTTS_OFF R11U266_SGNLITTS_OFF"
cd "$H/cases" || exit 2
bash "$D/grid.sh" $out.grid.txt VA/* VS/*
python3 "$D/gridsum.py" $out.grid.txt > $out.gridsum.txt
( cd $S/g && bash "$D/awayall.sh" P L $(ls -d tp/v11u266repro/cases/V*/*) ) > $out.away.txt
for cv in $(grep ' rec ' $out.away.txt | awk '{print $1}'); do
  w=$S/g/$cv; cmp -s $w/P.uhdm $w/L.uhdm && continue
  echo "$cv $(python3 "$D/awaychain.py" $w/gold_*/golden.uhdm $w/P.uhdm $w/L.uhdm | head -1)"
done > $out.chain.txt
for t in pristine law; do SLANG_UHDM=$B/$t python3 "$D/dscases.py" $t $S/ds VA/* VS/* > $out.ds_$t.txt; done
