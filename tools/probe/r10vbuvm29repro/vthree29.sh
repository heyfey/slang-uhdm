#!/usr/bin/env bash
# r10vbuvm29 VERIFIER three-way arm runner: golden (Surelog) vs PRI vs PAT,
# ONE view per invocation.  Records rc for EVERY invocation (verify_golden.py
# hides rc=139 segfaults as SLANG_REJECT -- an arm must not).  Writes a
# per-arm workdir under $VWD and prints one summary line per binary.
set -u
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
DUMP=$HOME/.local/bin/uhdm-dump
MODE=${MODE:-def}
PRI=${PRI:?}; PAT=${PAT:?}
CEN=${CEN:-/tmp/vbuvm29_ct29cen}
SRC="$1"
BASE=$(basename "$SRC" .sv)
W=${VWD:-/tmp/vbuvm29_arms}/${BASE}_${MODE}
rm -rf "$W"; mkdir -p "$W" || exit 9
cp "$SRC" "$W/"
leaf=$(basename "$SRC")
cd "$W" || exit 9
if [ "$MODE" = elab ]; then SLFLAG="-elabuhdm"; SUFLAG="--elabuhdm"; else SLFLAG=""; SUFLAG=""; fi
$SURELOG -parse -nocache -nowritecache -d coveruhdm $SLFLAG "$leaf" > sl.log 2>&1 </dev/null
echo "$BASE/$MODE SURELOG rc=$?"
G=$(find . -name '*.uhdm' | head -1)
for K in PRI PAT; do
  B=$(eval echo \$$K)
  "$B" $SUFLAG "$leaf" -o $K.uhdm > $K.log 2>&1 </dev/null
  echo "$BASE/$MODE $K rc=$?"
done
[ -n "$G" ] || { echo "$BASE/$MODE NO-GOLDEN"; exit 0; }
for K in PRI PAT; do
  if [ ! -f $K.uhdm ]; then echo "$BASE/$MODE $K NO-DATABASE"; continue; fi
  $CMP "$G" $K.uhdm > $K.cmp 2>&1
  n=$(grep -c . $K.cmp; true); h=$(grep -c '^LHS:' $K.cmp; true)
  v=PASS_CMP; [ "$n" != 0 ] && v=FAIL_CMP
  echo "$BASE/$MODE $K cmplines=$n heads=$h $v"
done
$DUMP "$G" 2>/dev/null </dev/null | sed 1d > G.dump
[ -f PRI.uhdm ] && $DUMP PRI.uhdm 2>/dev/null </dev/null | sed 1d > PRI.dump
[ -f PAT.uhdm ] && $DUMP PAT.uhdm 2>/dev/null </dev/null | sed 1d > PAT.dump
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
if [ -x "$CEN" ]; then
  "$CEN" "$G" 2>/dev/null | sort > G.cen
  [ -f PRI.uhdm ] && "$CEN" PRI.uhdm 2>/dev/null | sort > PRI.cen
  [ -f PAT.uhdm ] && "$CEN" PAT.uhdm 2>/dev/null | sort > PAT.cen
fi
echo "WORKDIR $W"
