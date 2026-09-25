#!/bin/bash
# gridall.sh <pristine> <law>: every case of cases/ on both binaries; one line per case.
P=$1; L=$2; D=$(cd $(dirname $0) && pwd); cd $D
for c in ../cases/*/*; do
  a=$(./grid.sh $c $P PRIS | awk '{print $3, $5}'); b=$(./grid.sh $c $L LAW | awk '{print $3, $5}')
  echo "$(echo $c | sed 's#../cases/##') | pristine: $a | law: $b"
done
