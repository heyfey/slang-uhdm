#!/bin/bash
# mirror.sh <sweep root> <corpus> <mirror root>: hard-link every slang.uhdm except the fenced tests' (word match on $FENCED)
source $(dirname $0)/env.sh
[ $(echo $FENCED | wc -w) -eq 4 ] || { echo "REFUSE: FENCED unset"; exit 9; }
re=$(echo $FENCED | tr ' ' '|')
src=$1/$2; dst=$3/$2; rm -rf $dst; mkdir -p $dst
cd $src && find . -name slang.uhdm | grep -v -w -E "($re)" | while read p; do mkdir -p $dst/$(dirname $p); ln $p $dst/$p; done
echo "$2: $(find $dst -name slang.uhdm | wc -l) of $(find $src -name slang.uhdm | wc -l)"
