#!/bin/bash
# v11u279 (adversarial verification of r11u279): how every number in ../README.md was measured, with the
# implementer's drivers (tools/probe/r11u279repro/drivers; paths resolve from this checkout).
# Export B (frozen binaries: pristine, law, uhdm-strictcmp, strictcmp_x built by r11u279repro/drivers/cc_x.sh)
# and S (scratch root) plus SURELOG, UHDM_CMP, UHDM_DUMP; the fence is read from r11u107repro/canaudit.sh by env.sh.
#   run.sh grid       : every case of cases/ in both views on P, L, OFF and each switch  -> $S/grid.txt
#   run.sh away       : order-blind + chain-keyed away census of the non-entering movers -> stdout
#   run.sh downstream : downstream_uhdm2rtlil.one() per case dir on pristine and law     -> $S/ds_{P,L}.txt
#   run.sh controls <repro dir>... : byte controls (pristine vs law, both views)         -> $S/controls.txt
H=$(cd "$(dirname "$0")/.." && pwd); D=$(cd "$H/../r11u279repro/drivers" && pwd)
. "$D/env.sh" || exit 2
case "$1" in
  grid) bash "$D/grid.sh" "$S/grid.txt" $(ls -d "$H"/cases/*/*) && python3 "$D/gridsum279.py" "$S/grid.txt" ;;
  away) python3 "$D/gridsum279.py" "$S/grid.txt" | grep ' by ' | grep -v 'STRICT_EQUAL_[0-9]*_objects *by' | awk '{print $1}' |
          xargs bash "$D/awaycv.sh" P L ;;
  downstream) mkdir -p "$S/ds"; for t in pristine law; do SLANG_UHDM=$B/$t python3 "$D/dscases.py" $t "$S/ds" $(ls -d "$H"/cases/*/*) > "$S/ds_$t.txt"; done ;;
  controls) shift; bash "$D/controls.sh" "$S/controls.txt" "$@" ;;
  *) echo "usage: run.sh grid|away|downstream|controls <dirs>" >&2; exit 2 ;;
esac
