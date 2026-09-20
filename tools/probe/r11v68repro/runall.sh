set -u
BIN=$1; TAG=$2
for f in all/*.sv; do bash run66.sh $f $TAG $BIN 2>&1 | grep -E 'ARM|FAILED'; done
for f in ca/*.sv; do bash run66.sh $f $TAG $BIN 2>&1 | grep -E 'ARM|FAILED'; done
