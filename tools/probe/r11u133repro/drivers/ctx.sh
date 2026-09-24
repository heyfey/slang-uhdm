#!/bin/bash
# ctx.sh <row label> [pairs file] : first 3 differing records of the row with ancestors
r=$1; P=${2:-/tmp/r11u133_x/corpus_pairsA.tsv}
l=$(grep -P "^$r\t" $P)
g=$(echo "$l" | cut -f2); o=$(echo "$l" | cut -f3)
/tmp/r11u133_x/strictcmp_x --max 3 --dump-a /tmp/r11u133_x/c.a --dump-b /tmp/r11u133_x/c.b $g $o > /tmp/r11u133_x/c.out
for n in $(grep -o "^#[0-9]*" /tmp/r11u133_x/c.out | tr -d '#'); do python3 /tmp/r11u133_x/drv/anc.py /tmp/r11u133_x/c.a /tmp/r11u133_x/c.b $n 0; done
