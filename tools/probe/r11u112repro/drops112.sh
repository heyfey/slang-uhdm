#!/bin/bash
# drops112.sh <grid-dir> <out> <law-binary> <pristine-binary>: each law's kill switch alone
# (and R11U112_OFF for all), u2r form, every grid arm: prints per switch the arms whose
# database differs from the LAW binary's (i.e. the arms that law moves) and whether the
# dropped database equals PRISTINE byte for byte.
G=${1:?grid}; O=${2:?out}; L=${3:?law}; P=${4:?pris}
mkdir -p "$O"
LIST=$(cd "$G" && find . -name dut.sv | sort)
run() { # <tag> <env...>
  local tag=$1; shift
  for rel in $LIST; do arm=$(dirname "${rel#./}"); k=$(echo "$arm" | tr / _)
    (cd "$G/$arm" && env "$@" timeout 300 "$BIN" dut.sv --single-unit --nobuiltin -o "$O/$k.$tag.uhdm" </dev/null >/dev/null 2>&1); done; }
BIN=$P run pris X=1
BIN=$L run law X=1
for sw in R11U112_OFF R11U112_PROPDIS_OFF R11U112_TDCAST_OFF R11U112_TDRET_OFF R11U112_TPNET_OFF R11U112_GENIPS_OFF R11U112_SELIDXTS_OFF R11U112_GENLPOP_OFF; do
  BIN=$L run "$sw" "$sw=1"
  moved=""; notpris=""
  for rel in $LIST; do arm=$(dirname "${rel#./}"); k=$(echo "$arm" | tr / _)
    cmp -s "$O/$k.$sw.uhdm" "$O/$k.law.uhdm" || { moved="$moved $arm"; cmp -s "$O/$k.$sw.uhdm" "$O/$k.pris.uhdm" || notpris="$notpris $arm"; }
  done
  echo "$sw MOVED:$(echo $moved | wc -w) [$moved ] NOT-PRISTINE:[$notpris ]"
done
