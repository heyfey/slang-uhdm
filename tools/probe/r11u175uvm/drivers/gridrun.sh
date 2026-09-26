#!/bin/bash
# gridrun.sh <pristine> <law> [case dir...]: every case of cases/ judged (uhdm-cmp + uhdm-strictcmp vs the pinned
# Surelog's golden, case.sh) under the pristine binary, the law binary, and the law binary with each r11u175
# switch set alone; one line per case: the strict verdicts in that order. Fail-closed on $FENCED (case.sh).
set -u; : "${FENCED:?FENCED unset}"; P=$1; L=$2; shift 2
D=$(cd "$(dirname "$0")" && pwd); C=${@:-$(ls -d $D/../cases/*/*)}
v(){ sed 's/.*strict=[0-9]* //; s/ |.*//; s/STRICT_EQUAL.*/EQUAL/; s/STRICT_NOTEQUAL /SNE:/; s/NOT_EQUAL stage1/NE/' ; }
printf '%-40s %-14s %-14s %-14s %-14s %-14s %-14s\n' case pristine law MULT_OFF FSPAN_OFF FULLNAME_OFF ESPAN_OFF
for c in $C; do
  r="$(TAG=gP bash $D/case.sh $c $P | v) $(TAG=gL bash $D/case.sh $c $L | v)"
  for sw in R11U175_MULT_OFF R11U175_FSPAN_OFF R11U175_FULLNAME_OFF R11U175_ESPAN_OFF; do
    r="$r $(env $sw=1 TAG=g$sw bash $D/case.sh $c $L | v)"; done
  printf '%-40s %s\n' "$(echo $c | sed 's|.*/cases/||')" "$r"
done
