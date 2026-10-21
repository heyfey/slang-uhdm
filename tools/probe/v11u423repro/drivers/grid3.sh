#!/bin/bash
# v11u423 grid3: per case dir, pristine / law / verified (case.sh lines with exit code),
# R11U423_OFF on verified -> pristine's bytes and exit code, R11V423_OFF on verified -> law's,
# and the single law switches on verified that restore pristine.
# usage: grid3.sh <pristine> <law> <verified> <out> <casedir>...
P=$1; L=$2; V=$3; OUT=$4; shift 4; : > $OUT; H=$(dirname $(readlink -f $0))
SW="R11U423_CIOPS_OFF R11U423_CILATE_OFF R11U423_CICLSOWN_OFF R11U423_CLSOPLATE_OFF R11U423_UNSZFOLD_OFF R11U423_DECUNSZ_OFF R11U423_OCTUNSZ_OFF"
m() { echo "$1" | sed 's/.*rc=\([0-9]*\).*md5=\([0-9a-f]*\).*/\1:\2/'; }
for c in "$@"; do
 p=$(bash $H/case.sh $c $P); l=$(bash $H/case.sh $c $L); v=$(bash $H/case.sh $c $V)
 o=$(bash $H/case.sh $c $V R11U423_OFF=1); f=$(bash $H/case.sh $c $V R11V423_OFF=1)
 own=""; if [ "$(m "$v")" != "$(m "$p")" ]; then for s in $SW; do w=$(bash $H/case.sh $c $V $s=1); [ "$(m "$w")" = "$(m "$p")" ] && own="$own ${s#R11U423_}"; done; fi
 echo "$(basename $(dirname $c))/$(basename $c) | P ${p#* } | L ${l#* } | V ${v#* } | U423OFF=pris:$([ "$(m "$o")" = "$(m "$p")" ] && echo y || echo N) V423OFF=law:$([ "$(m "$f")" = "$(m "$l")" ] && echo y || echo N) VvsL:$([ "$(m "$v")" = "$(m "$l")" ] && echo same || echo MOVED) restoredBy:${own:- -}" >> $OUT
done
