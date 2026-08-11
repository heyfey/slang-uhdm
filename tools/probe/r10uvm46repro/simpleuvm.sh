#!/bin/bash
# r10uvm46 (cloned from pass 45) (cloned from pass 44) — run ONE UVM-4 test's slang side by hand (the harness argv, copied
# from its cmds.txt) so an env-gated emitter TRACE can be captured.  The sweep
# swallows stderr, and this arm's whole question ("which of the two registry
# objects does this call site take?") is only answerable from inside the walk.
#   usage: simpleuvm.sh <out-dir> [binary] [test]
set -u
ROOT=$(cd "$(dirname "$0")"/../../.. && pwd)
OUT=${1:?}
BIN=${2:-$ROOT/build/slang-uhdm}
T=${3:-SimpleUVM}
SL=$HOME/git-repos/Surelog
mkdir -p "$OUT" || exit 1
cd "$OUT" || exit 1
case $T in
  SimpleUVM|SeqDriver|BuildUVMPkg|Scoreboard) ;;
  *) echo "unknown test $T"; exit 1;;
esac
UVM=$SL/third_party/UVM/uvm-1.2/src
[ -d "$SL/tests/$T" ] && TD=$SL/tests/$T || TD=$SL/third_party/tests/$T
SRC=""
for f in "$TD"/*.sv "$TD"/*.svh; do [ -f "$f" ] && SRC="$SRC $f"; done
# shellcheck disable=SC2086
"$BIN" "+incdir+$TD+$UVM/" "$UVM/uvm_pkg.sv" $SRC --single-unit \
       -o "$OUT/slang.uhdm"
echo "rc=$?"
