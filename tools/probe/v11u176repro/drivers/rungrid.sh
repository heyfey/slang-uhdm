#!/bin/bash
# rungrid.sh <list> <tag> <bin> <out>  (env passes through: R11U176_* switches)
L=$1; T=$2; B=$3; O=$4
xargs -a $L -P 3 -I{} /tmp/v11u176_case.sh /tmp/v11u176_cases/{} $T $B | sort > $O
