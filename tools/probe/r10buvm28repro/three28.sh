#!/bin/bash
# r10buvm28 three-way arm runner: golden (Surelog) vs PRI vs PAT, BOTH views.
# usage: PRI=<bin> PAT=<bin> MODE=def|elab ./three28.sh <file.sv> [more.sv]
set -u
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
MODE=${MODE:-def}
SRC="$@"
BASE=$(basename "$1")
W=$(mktemp -d /tmp/r10buvm28_three_XXXXXX)
for f in $SRC; do cp "$f" $W/; done
cd $W
FILES=""; for f in $SRC; do FILES="$FILES $(basename $f)"; done
if [ "$MODE" = elab ]; then SLFLAG="-elabuhdm"; SUFLAG="--elabuhdm"; else SLFLAG=""; SUFLAG=""; fi
$SURELOG -parse -nocache -nowritecache -d coveruhdm $SLFLAG $FILES > sl.log 2>&1
G=$(find . -name '*.uhdm' | head -1)
for K in PRI PAT; do
  B=$(eval echo \$$K)
  "$B" $SUFLAG $FILES --single-unit --nobuiltin -o $K.uhdm > $K.log 2>&1
  echo "$K rc=$?"
done
for K in PRI PAT; do
  n=$($CMP "$G" $K.uhdm 2>&1 | grep -c .)
  h=$($CMP "$G" $K.uhdm 2>&1 | grep -c '^LHS:')
  echo "$BASE/$MODE $K cmplines=$n heads=$h"
  $CMP "$G" $K.uhdm > $K.cmp 2>&1
done
$HOME/.local/bin/uhdm-dump "$G" > G.dump 2>&1
$HOME/.local/bin/uhdm-dump PRI.uhdm > PRI.dump 2>&1
$HOME/.local/bin/uhdm-dump PAT.uhdm > PAT.dump 2>&1
echo "WORKDIR $W"
