#!/bin/bash
# r10buvm29 three-way arm runner: golden (Surelog) vs PRI vs PAT, BOTH views.
# usage: PRI=<bin> PAT=<bin> MODE=def|elab ./three29.sh <file.sv> [more.sv]
# Records rc for EVERY invocation (verify_golden.py hides rc=139 segfaults as
# SLANG_REJECT -- an arm must not).
set -u
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
MODE=${MODE:-def}
SRC="$@"
BASE=$(basename "$1")
W=$(mktemp -d /tmp/r10buvm29_three_XXXXXX)
for f in $SRC; do cp "$f" $W/; done
cd $W
FILES=""; for f in $SRC; do FILES="$FILES $(basename $f)"; done
if [ "$MODE" = elab ]; then SLFLAG="-elabuhdm"; SUFLAG="--elabuhdm"; else SLFLAG=""; SUFLAG=""; fi
$SURELOG -parse -nocache -nowritecache -d coveruhdm $SLFLAG $FILES > sl.log 2>&1
echo "$BASE/$MODE SURELOG rc=$?"
G=$(find . -name '*.uhdm' | head -1)
for K in PRI PAT; do
  B=$(eval echo \$$K)
  "$B" $SUFLAG $FILES --single-unit -o $K.uhdm > $K.log 2>&1
  echo "$BASE/$MODE $K rc=$?"
done
for K in PRI PAT; do
  [ -f $K.uhdm ] || { echo "$BASE/$MODE $K NO-DATABASE"; continue; }
  $CMP "$G" $K.uhdm > $K.cmp 2>&1
  n=$(grep -c . $K.cmp; true)
  h=$(grep -c '^LHS:' $K.cmp; true)
  v=PASS_CMP; [ "$n" != 0 ] && v=FAIL
  echo "$BASE/$MODE $K cmplines=$n heads=$h $v"
done
$HOME/.local/bin/uhdm-dump "$G" > G.dump 2>&1
[ -f PRI.uhdm ] && $HOME/.local/bin/uhdm-dump PRI.uhdm > PRI.dump 2>&1
[ -f PAT.uhdm ] && $HOME/.local/bin/uhdm-dump PAT.uhdm > PAT.dump 2>&1
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
CEN=${CEN:-/tmp/r10buvm29_ct29cen}
[ -x "$CEN" ] && { "$CEN" "$G" | sort > G.cen; [ -f PRI.uhdm ] && "$CEN" PRI.uhdm | sort > PRI.cen; [ -f PAT.uhdm ] && "$CEN" PAT.uhdm | sort > PAT.cen; }
echo "WORKDIR $W"
