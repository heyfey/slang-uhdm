#!/bin/bash
# r10uvm45 (cloned from pass 44) — LSTOTAL, the TYPESPEC-LISTING census diff (r10uvm44ls) against
# golden, per UVM-4 test, out of a sweep workdir.
#
# WHY A THIRD CONTAINER/LISTING METRIC.  LISTDIRECT counts referrers FROM THE
# LISTING OBJECT'S SIDE; CPTOTAL asks what object sits in a container POSITION.
# Both are blind to an object THAT DOES NOT EXIST — nobody refers to it and it
# occupies no position — and pass 43's ranked #1 was exactly that: a POPULATION
# deficit.  The listing vector itself is the only place a missing entry shows,
# and it is the first thing uhdm-cmp reads (a vector SIZE mismatch reports as
# `r=1 failLhs=<container>`).
#
#   usage: ls.sh <sweep-workdir> <tag> [test ...]
# Per test: the SCOPE-level diff (how many listing vectors disagree at all) and
# the ENTRY-level diff (how many individual kind:name entries disagree), which
# is LSTOTAL.  Both are reported because they answer different questions and a
# scope count saturates at 1 per scope however large the deficit is.
set -u
ROOT=$(cd "$(dirname "$0")"/../../.. && pwd)
cd "$ROOT" || exit 1
WD=${1:?}
TAG=${2:?}
shift 2
TESTS=${*:-"BuildUVMPkg Scoreboard SeqDriver SimpleUVM"}
V=/tmp/r10uvm45_r10uvm44ls
TOT=0
STOT=0
for T in $TESTS; do
  D=$(ls -d "$WD"/default/$T-* 2>/dev/null | head -1)
  [ -n "$D" ] || { echo "$T: no workdir under $WD"; continue; }
  G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[0-9a-f]*" "$D/cmds.txt" | head -1)/golden.uhdm
  "$V" "$G"                 > "/tmp/r10uvm45_ls_g_$T.txt"         2>/dev/null
  "$V" "$D/slang.uhdm"      > "/tmp/r10uvm45_ls_${TAG}_$T.txt"    2>/dev/null
  "$V" "$G"            "" -e > "/tmp/r10uvm45_lse_g_$T.txt"       2>/dev/null
  "$V" "$D/slang.uhdm" "" -e > "/tmp/r10uvm45_lse_${TAG}_$T.txt"  2>/dev/null
  S=$(diff "/tmp/r10uvm45_ls_g_$T.txt" "/tmp/r10uvm45_ls_${TAG}_$T.txt" \
      | grep -c '^[<>]')
  N=$(diff "/tmp/r10uvm45_lse_g_$T.txt" "/tmp/r10uvm45_lse_${TAG}_$T.txt" \
      | grep -c '^[<>]')
  TOT=$((TOT + N))
  STOT=$((STOT + S))
  echo "$T scopes golden=$(wc -l < "/tmp/r10uvm45_ls_g_$T.txt") ours=$(wc -l < "/tmp/r10uvm45_ls_${TAG}_$T.txt") scopediff=$S entrydiff=$N"
done
echo "LSTOTAL[$TAG] = $TOT   (scope-level $STOT)"
