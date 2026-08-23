#!/usr/bin/env bash
# r10earl74 — MOVER PREDICTION over a PRISTINE sweep workdir, using inhchk74
# (which reads each pristine database ALONE).  Stage 1 is a deliberate
# OVER-approximation: it matches a bound to a param_assign on the DECOMPILE
# DIGITS, because the sizing parameter's NAME is not recorded in the database.
# Stage 2 is reading the source of every stage-1 hit.
#
#   usage: INHCHK=/abs/inhchk74 ./predict74.sh <sweep-workdir> <out.txt>
# MEASUREMENT ONLY.  The four slang-fenced tests are never dispatched: this
# only READS databases a sweep already produced.
set -u
CHK=${INHCHK:?set INHCHK to the inhchk74 binary}
WD=${1:?sweep workdir}; OUT=${2:?out}
n=0; hits=0; : > "$OUT"
for db in $(find "$WD" -name 'slang.uhdm' | sort); do
  n=$((n+1))
  c=$(timeout 900 "$CHK" "$db" 2>/dev/null | tail -1); c=${c#TOTAL }
  case "$c" in ""|0) ;; *) hits=$((hits+1)); echo "$c $db" >> "$OUT";; esac
done
echo "scanned=$n flagged=$hits"
