#!/bin/bash
# v11u401 show.sh <case> <view> [max]: uhdm-cmp head + strict verdict for pristine and law
H=$(cd "$(dirname "$0")" && pwd); source $H/env.sh; export R401_GOLD=/tmp/v11u401_gold R401_OUT=/tmp/v11u401_caseout
for b in pris law; do echo "== $b"; SHOW=1 bash $H/case.sh $H/../cases/$1 $VB/slang-uhdm.$b $2 ${3:-8}; done
