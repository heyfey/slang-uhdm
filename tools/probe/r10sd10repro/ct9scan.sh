#!/usr/bin/env bash
# r10sd9 — run ct9pred over EVERY database a verify_golden sweep produced, in
# the mode that makes the number a PREDICTION: on the PRISTINE workdir, before
# any delivered database has been compared.
#
#   usage: CT9PRED=/tmp/r10sd9_pred ./ct9scan.sh <workdir-root>
#
# The golden for each database is read out of that run's own `cmds.txt`
# (`surelog: (golden cache hit <dir>)`), so the pairing is the harness's own and
# not a guess.  A database whose cmds.txt names no cache entry is reported as
# NO_GOLDEN and counted — a silently skipped row is how a scan reads clean.
#
# GUARD (measure the measurer): zero databases scanned is exit 5.
set -u
WD=${1:?workdir root}
PRED=${CT9PRED:-/tmp/r10sd9_pred}
[ -x "$PRED" ] || { echo "FATAL: no ct9pred at $PRED"; exit 3; }
n=0; nog=0; hit=0; tot=0
while read -r db; do
  n=$((n + 1))
  d=$(dirname "$db")
  g=$(sed -n 's/.*golden cache hit \([^)]*\)).*/\1/p' "$d/cmds.txt" 2>/dev/null | head -1)
  if [ -z "$g" ] || [ ! -f "$g/golden.uhdm" ]; then
    nog=$((nog + 1)); continue
  fi
  line=$("$PRED" "$g/golden.uhdm" "$db" 2>/dev/null | grep '^\[S\] PREDICT')
  r=$(echo "$line" | sed -E 's/.* reachable=([0-9]+).*/\1/')
  [ -n "$r" ] || continue
  if [ "$r" -gt 0 ]; then
    hit=$((hit + 1)); tot=$((tot + r))
    echo "PREDICT ${db#$WD/}  reachable=$r"
  fi
done < <(find "$WD" -name slang.uhdm -type f | sort)
echo "[S] scanned=$n no_golden=$nog databases_with_rows=$hit total_rows=$tot"
[ "$n" -gt 0 ] || { echo "REFUSING TO REPORT: no databases scanned"; exit 5; }
