#!/bin/bash
# v11u93_head.sh <cmp.log>: print the first object line after LHS: and after RHS:
f=$1
l=$(awk '/^LHS:/{f=1;next} f&&/^decompile:/{next} f&&NF{print;exit}' "$f")
r=$(awk '/^RHS:/{ if ($0 ~ /<null>/) {print "<null>"; exit}; f=1;next} f&&/^decompile:/{next} f&&NF{print;exit}' "$f")
echo "L: $l"; echo "R: $r"
