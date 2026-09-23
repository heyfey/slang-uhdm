#!/usr/bin/env bash
# r11u109 WIDE BOUNDARY (r11u106repro/bnd106.sh, copied unchanged in logic) — run the PRISTINE and the LAW binary over one committed
# probe arm and report whether the two databases differ.
#
# PATH-NEUTRAL BY CONSTRUCTION: the serializer embeds the output path in the
# database, so a two-directory pairing reads DIFFERS on everything and proves
# nothing (r11v68 §4).  Both binaries therefore write the SAME file name in the
# SAME directory, one after the other, and the first database is copied aside
# before the second runs.
#
# usage:  BND_PRIS=<bin> BND_LAW=<bin> BND_ROOT=<probe dir> BND_OUT=<dir> \
#         bnd72.sh <arm path relative to BND_ROOT>
set -u
PRIS=${BND_PRIS:?set BND_PRIS}
LAW=${BND_LAW:?set BND_LAW}
ROOT=${BND_ROOT:?set BND_ROOT}
OUT=${BND_OUT:?set BND_OUT}
A=${1:?arm}
# key the scratch on the RELATIVE path: several arms are called `dut.sv`
K=$(printf '%s' "$A" | tr '/.' '__')
D=$OUT/$K
rm -rf "$D"; mkdir -p "$D"
F=$ROOT/$A
( cd "$D" && timeout 300 "$PRIS" "$F" --single-unit -o out.uhdm > p.log 2>&1 )
prc=$?
[ -f "$D/out.uhdm" ] && mv "$D/out.uhdm" "$D/pris.uhdm"
( cd "$D" && timeout 300 "$LAW" "$F" --single-unit -o out.uhdm > l.log 2>&1 )
lrc=$?
[ -f "$D/out.uhdm" ] && mv "$D/out.uhdm" "$D/law.uhdm"
if [ ! -f "$D/pris.uhdm" ] || [ ! -f "$D/law.uhdm" ]; then
  echo "ARM $A prc=$prc lrc=$lrc NODB"
  exit 0
fi
if cmp -s "$D/pris.uhdm" "$D/law.uhdm"; then
  echo "ARM $A prc=$prc lrc=$lrc SAME"
  rm -rf "$D"
else
  echo "ARM $A prc=$prc lrc=$lrc DIFFERS"
fi
