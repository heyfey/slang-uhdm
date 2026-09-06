#!/usr/bin/env bash
# r10uvm172repro/predict172.sh — THE A-PRIORI MOVER PREDICTION, made from the
# PRISTINE databases alone, BEFORE the patched sweep runs.  MEASUREMENT ONLY.
#   predict172.sh <pristine-workdir>
#
# `ct172cen --pred` lists, from ONE database, every statement-position
# method_func_call/method_task_call whose vpiPrefix NAME is also the name of
# some function or task IN THAT DATABASE.  That is a deliberate SUPERSET of
# what § recvNamesSubroutineCollapsesStmtCall172 can fire on (it ignores WHICH
# scope the subroutine lives in, which only slang knows), so a row that prints
# nothing here CANNOT move — the safe direction for a prediction.
#
# GUARDS: a missing database is printed as SKIP and COUNTED; the row count is
# asserted nonzero, because a predictor that reached nothing would otherwise
# read as "no movers".
set -u
WD=${1:?workdir}
CEN=${CT172CEN:-/tmp/r10uvm172_ct172cen}
[ -x "$CEN" ] || { echo "FATAL: no ct172cen at $CEN"; exit 3; }
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
n=0; skip=0; hit=0
for mode in default testflags; do
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    row=$(basename "$d"); row=${row%-*}
    O=$d/slang.uhdm
    [ -f "$O" ] || { skip=$((skip+1)); continue; }
    c=$("$CEN" "$O" --pred 2>/dev/null | grep -c '^PRED' ; true)
    n=$((n+1))
    if [ "$c" != 0 ]; then
      hit=$((hit+1))
      printf "CANDIDATE %-28s %-9s cells=%s\n" "$row" "$mode" "$c"
      "$CEN" "$O" --pred 2>/dev/null | grep '^PRED' | sed "s#^#    $row $mode #"
    fi
  done
done
echo "-- scanned=$n SKIP=$skip ROWS-WITH-CANDIDATES=$hit"
[ "$n" -gt 0 ] || { echo "FATAL: the predictor reached no database"; exit 4; }
