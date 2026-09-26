#!/bin/bash
# obd.sh <casedir> : order-blind distance (multiset of stripped dump lines) golden vs pris / law
source /tmp/v11u171_scr/env.sh
C=$(readlink -f $1); cd $C
K=$(cat dut.sv | sha1sum | cut -c1-16)-$(echo dut.sv | tr '\n' ' ' | sha1sum | cut -c1-6)
n=$(echo $C | sed 's|.*/v11u171_cases/||' | tr / _)
norm() { $UHDM_DUMP $1 2>&1 | sed 's/^[ |\\_]*//; s#/tmp/[^ ]*##g' | grep -v '^$' | sort; }
norm /tmp/v11u171_gold/$K/golden.uhdm > /tmp/v11u171_scr/ob.g
for b in pris law; do norm /tmp/v11u171_caseout/$n.$b/ours.uhdm > /tmp/v11u171_scr/ob.$b; done
a=$(comm -13 /tmp/v11u171_scr/ob.g /tmp/v11u171_scr/ob.pris | wc -l); b=$(comm -13 /tmp/v11u171_scr/ob.g /tmp/v11u171_scr/ob.law | wc -l)
a2=$(comm -23 /tmp/v11u171_scr/ob.g /tmp/v11u171_scr/ob.pris | wc -l); b2=$(comm -23 /tmp/v11u171_scr/ob.g /tmp/v11u171_scr/ob.law | wc -l)
echo "$n oursNotGolden pris=$a law=$b  goldenNotOurs pris=$a2 law=$b2"
