#!/usr/bin/env bash
# r10v118 VERIFIER's OWN a-priori mover predictor, run on PRISTINE databases
# only.  Fingerprint = a vpiCastOp operation whose Actual_typespec is a LOC-LESS
# NAMELESS logic_typespec.  Deliberately BROADER than the implementer's (no
# parent constraint), so a mover with a different parent cannot hide.
set -u
WD=${1:?pristine workdir}
CEN=${2:-/tmp/v118_arm/ct118cen}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
find "$WD" -name slang.uhdm | sort | while read -r db; do
  rel=${db#$WD/}
  n=$("$CEN" "$db" --cast 2>/dev/null | grep -c 'TS=logic_typespec	TSLOC=0	TSNAME=-'); true
  [ "${n:-0}" -gt 0 ] && echo -e "$n\t$rel"
done
