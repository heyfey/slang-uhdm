#!/bin/bash
# grid.sh <bin> <tag> <out>: runcase over every case dir of this pass
D=$(dirname "$0"); : > $3
for c in $(find $D/../cases -mindepth 2 -maxdepth 2 -type d | sort); do bash $D/runcase.sh $1 $2 $c >> $3; done
