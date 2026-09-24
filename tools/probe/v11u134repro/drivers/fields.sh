#!/bin/bash
# fields.sh <case name>  -> P and L strict fields lines
w=$(grep -l "/$1\$" /tmp/v11u134_cases/*/dir | xargs dirname)
for t in P L; do echo "$1 $t: $(/tmp/v11u134_bin/strictcmp --max 0 $w/golden.uhdm $w/$t.uhdm 2>&1 | grep -E '^fields|^objects' | tr '\n' ' ')"; done
