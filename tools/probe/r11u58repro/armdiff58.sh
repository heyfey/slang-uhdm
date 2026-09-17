#!/bin/bash
# r11u58 — order-blind residue for a GRID arm (golden vs a chosen tag's dump).
# usage: armdiff58.sh <armdir> <tag>
set -u
D=${1:?arm}; T=${2:?tag}
sed -e "s#$D/##g" -e 's#/home/heyfey/[^ ,)]*/##g' $D/gold.$T.dump | sort > /tmp/r11u58_ad.g
sed -e "s#$D/##g" -e 's#/home/heyfey/[^ ,)]*/##g' $D/ours.$T.dump | sort > /tmp/r11u58_ad.o
diff /tmp/r11u58_ad.g /tmp/r11u58_ad.o > /tmp/r11u58_ad.d; true
echo "$(basename $D) $T gonly=$(grep -c '^<' /tmp/r11u58_ad.d; true) oonly=$(grep -c '^>' /tmp/r11u58_ad.d; true)"
