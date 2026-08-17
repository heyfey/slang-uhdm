#!/usr/bin/env bash
# r10uvm84 — the MOVER PREDICTOR, run over a WHOLE sweep workdir of PRISTINE
# databases.  MEASUREMENT-ONLY.
#
#   usage: pred84.sh <workdir> [<ct84cen>]
#
# Prints one line per database with PRED>0 (the predicted movers) and the totals.
# PRED is an UPPER BOUND and says so: our pristine hier_path NAME has its indices
# ERASED, so `this.ha[i].fld` (which golden ALSO spells as a hier_path, and which
# the shipped predicate DECLINES on the written text) is indistinguishable by name
# from `this.h.arr[i]` (which it accepts).  A database whose only PRED hits are of
# the first-step-indexed kind is predicted a mover and will be byte-identical.
set -u
WD=${1:?workdir}
CEN=${2:-/tmp/r10uvm84_ct84cen}
[ -x "$CEN" ] || { echo "FATAL: no census tool $CEN"; exit 3; }
tot=0; nz=0
while read -r db; do
  tot=$((tot+1))
  line=$("$CEN" "$db" | tail -1)
  p=$(printf '%s' "$line" | sed -n 's/.*PRED=\([0-9]*\).*/\1/p')
  m=$(printf '%s' "$line" | sed -n 's/.*MOCKUP=\([0-9]*\).*/\1/p')
  if [ "${p:-0}" -gt 0 ]; then
    nz=$((nz+1))
    rel=${db#$WD/}
    printf "PRED\t%-58s pred=%-5s mockup=%s\n" "${rel%/slang.uhdm}" "$p" "$m"
  fi
done < <(find "$WD" -name slang.uhdm | sort)
echo "-- databases=$tot  PRED-nonzero=$nz"
