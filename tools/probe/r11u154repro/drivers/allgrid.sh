#!/bin/bash
# allgrid.sh <binA> <binB>: grid.sh over every case of this repro (pristine vs law), one line per case
D=$(cd "$(dirname "$0")" && pwd); R=$(dirname $D)
bash $D/grid.sh "$1" "$2" $(find $R -mindepth 2 -maxdepth 2 -type d ! -path '*/drivers*' ! -path '*/evidence*' | sort)
