#!/bin/bash
# CMP-relevant projection of the probe output: BaseClass::Compare uses only
# VpiType/VpiName/VpiDefName -- NOT VpiParent, NOT line/col. ref_typespec
# compares VpiName+VpiDefName+Actual, never VpiFullName. So strip par=,
# ref/alias/base/elem fullnames, and source locations.
N=$1
for side in pg ps; do
  sed -e 's/ par=[^ ]*//g' \
      -e "s/ ref '[^']*'/ ref/" \
      -e 's/\(alias->\|base->\|elem->\) .*/\1/' \
      -e 's/[0-9]\+:[0-9]\+-[0-9]\+:[0-9]\+//g' \
      -e 's/,[0-9]\+:[0-9]\+-[0-9]\+:[0-9]\+}/}/g' \
      -e 's/@$//' \
      /tmp/w4f_${N}_${side}.txt > /tmp/w4f_${N}_${side}n.txt
done
diff /tmp/w4f_${N}_pgn.txt /tmp/w4f_${N}_psn.txt > /tmp/w4f_${N}_n.diff
echo "cmp-relevant changed: $(grep -c '^[<>]' /tmp/w4f_${N}_n.diff)"
