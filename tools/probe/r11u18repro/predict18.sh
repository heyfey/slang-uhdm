#!/usr/bin/env bash
# predict18.sh — the a-priori mover prediction for r11u18, BY NAME, from the
# WRITTEN SOURCE (the law's own key is the written keyword, which is not in the
# database at all) plus the pristine databases for the leftover half.
#
#   L1 — § typeParamLocalKeyword18: every row whose sources contain a
#        `localparam` ... `type` parameter declaration.  A row without one
#        CANNOT move: the only field the law writes is vpiLocalParam on a
#        type_parameter, and it writes `true` only for that spelling.
#   L2 — § memLeftFormalReadTs18: every row whose PRISTINE database already
#        carries a struct typespec member LEFTOVER (a typespec_member with an
#        Actual_value) that is a CONSTANT WITHOUT a typespec.  That is the
#        superset the stamp can reach; the members it actually stamps are the
#        ones written from a whole formal read, which the database cannot say.
#   usage: predict18.sh <corpus-root> <workdir/mode> [out]
set -u
ROOT=${1:?corpus root}
WD=${2:?workdir mode dir}
UD=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
echo "== L1 (localparam type) sources under $ROOT"
grep -rIlE '(^|[^[:alnum:]_])localparam[[:space:]]+type[[:space:]]' "$ROOT" \
     --include='*.sv' --include='*.v' --include='*.svh' --include='*.vh' 2>/dev/null \
  | sed "s#^$ROOT/##" | cut -d/ -f1 | sort -u
echo "== L2 (leftover constant without a typespec) in $WD"
for d in "$WD"/*/; do
  [ -f "$d/slang.uhdm" ] || continue
  n=$(basename "$d"); n=${n%-*}
  timeout 300 "$UD" "$d/slang.uhdm" 2>/dev/null \
    | python3 "$(dirname "$0")"/memcells.py /dev/stdin 2>/dev/null \
    | grep -q 'ts=NONE' && echo "$n"
done | sort -u
