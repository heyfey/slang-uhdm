#!/usr/bin/env bash
# r11v81 THREE-WAY WIDE BOUNDARY — pristine, the implementer's law, and the
# verifier's fixed law over ONE committed probe arm, all three writing the SAME
# file name in the SAME directory (the serializer embeds the output path).
set -u
PRIS=${BND_PRIS:?}; LAW=${BND_LAW:?}; FIX=${BND_FIX:?}
ROOT=${BND_ROOT:?}; OUT=${BND_OUT:?}
A=${1:?arm}
K=$(printf '%s' "$A" | tr '/.' '__')
D=$OUT/$K
rm -rf "$D"; mkdir -p "$D"
F=$ROOT/$A
( cd "$D" && timeout 300 "$PRIS" "$F" --single-unit -o out.uhdm > p.log 2>&1 ); prc=$?
[ -f "$D/out.uhdm" ] && mv "$D/out.uhdm" "$D/pris.uhdm"
( cd "$D" && timeout 300 "$LAW" "$F" --single-unit -o out.uhdm > l.log 2>&1 ); lrc=$?
[ -f "$D/out.uhdm" ] && mv "$D/out.uhdm" "$D/law.uhdm"
( cd "$D" && timeout 300 "$FIX" "$F" --single-unit -o out.uhdm > f.log 2>&1 ); frc=$?
[ -f "$D/out.uhdm" ] && mv "$D/out.uhdm" "$D/fix.uhdm"
if [ ! -f "$D/pris.uhdm" ] || [ ! -f "$D/law.uhdm" ] || [ ! -f "$D/fix.uhdm" ]; then
  echo "ARM $A prc=$prc lrc=$lrc frc=$frc NODB"; exit 0
fi
pl=SAME; pf=SAME; lf=SAME
cmp -s "$D/pris.uhdm" "$D/law.uhdm" || pl=DIFFERS
cmp -s "$D/pris.uhdm" "$D/fix.uhdm" || pf=DIFFERS
cmp -s "$D/law.uhdm"  "$D/fix.uhdm" || lf=DIFFERS
echo "ARM $A prc=$prc lrc=$lrc frc=$frc PL=$pl PF=$pf LF=$lf"
[ "$pl" = SAME ] && [ "$pf" = SAME ] && rm -rf "$D"
exit 0
