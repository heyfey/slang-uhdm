#!/bin/bash
# subset.sh <first_record.txt> <pairsP> <pairsL>: for every changed, not-EQUAL pair: is the law's set of differing
# (record index, field) a SUBSET of pristine's? (the whole walk, --max 1000000)
grep -v '^EQUAL' $1 | cut -f2 | while read lab; do
  a=$(grep -P "^$lab\t" $2); b=$(grep -P "^$lab\t" $3)
  /tmp/r11u145_bin/strictcmp --max 1000000 $(echo "$a"|cut -f2) $(echo "$a"|cut -f3) | grep -oE '^#[0-9]+ [a-z_]+' | sort > /tmp/r11u145_ss.p
  /tmp/r11u145_bin/strictcmp --max 1000000 $(echo "$b"|cut -f2) $(echo "$b"|cut -f3) | grep -oE '^#[0-9]+ [a-z_]+' | sort > /tmp/r11u145_ss.l
  new=$(comm -13 /tmp/r11u145_ss.p /tmp/r11u145_ss.l | wc -l); gone=$(comm -23 /tmp/r11u145_ss.p /tmp/r11u145_ss.l | wc -l)
  echo "$([ $new = 0 ] && echo SUBSET || echo NEW=$new) gone=$gone $lab"
done; rm -f /tmp/r11u145_ss.p /tmp/r11u145_ss.l
