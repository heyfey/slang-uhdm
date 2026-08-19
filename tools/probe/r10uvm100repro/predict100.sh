#!/usr/bin/env bash
# r10uvm100 — MEASUREMENT ONLY.  The A-PRIORI mover predictor.  Reads ONLY OUR
# PRISTINE databases (never golden, never the patched binary) and names every
# (mode, test) that CAN move under § parenStmtDelayNamelessRef100.
#
# THE PREDICATE.  The law touches exactly one shape: a PARENTHESISED delay
# value in STATEMENT position.  Our pristine emitter renders a `delay_control`
# carrying NEITHER a vpiDelay string NOR a Delay() object in exactly THREE
# places, and the other two are excluded BY OWNER KIND:
#   * vpiParent `assignment`      -- the INTRA-ASSIGNMENT delay, the other arm
#                                    of emitDelayControl, which this law leaves
#                                    exactly as it was;
#   * vpiParent `clocking_block`  -- a clocking SKEW, minted by a DIFFERENT
#                                    function (ModuleEmit.cpp emitClockingSkew)
#                                    that this patch never touches.  The LOOSE
#                                    predicate (owner-kind `assignment` alone)
#                                    over-predicts exactly here: it names
#                                    InterfaceModPort, whose two cells are
#                                    `default input #1step output #2` skews and
#                                    which byteverify measures as SAME.
# What is left is the statement-position parenthesised delay.  A database with
# no such object cannot move a byte.
#   ./predict100.sh <workdir> > PREDICT.txt
set -u
WD=${1:?workdir}
HERE=$(cd "$(dirname "$0")" && pwd)
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
TMP=$(mktemp /tmp/r10uvm100_pred.XXXXXX); trap 'rm -f "$TMP"' EXIT
tot=0; hit=0; alldc=0; intradc=0
while IFS= read -r db; do
  rel=${db#$WD/}; rel=${rel%/slang.uhdm}
  tot=$((tot+1))
  "$DUMP" "$db" 2>/dev/null </dev/null \
      | python3 "$HERE/dc100.py" /dev/stdin X 2>/dev/null > "$TMP" || true
  n=$(grep -c 'str=- ref=-' "$TMP" || true)
  m=$(grep 'str=- ref=-' "$TMP" | grep -cE 'OWNER (assignment|clocking_block)@' || true)
  a=$(grep -c 'dcspan=' "$TMP" || true)
  alldc=$((alldc+a)); intradc=$((intradc+m))
  k=$((n-m))
  [ "$k" -gt 0 ] && { hit=$((hit+1)); echo "PREDICT $rel parenStmtDc=$k"; }
done < <(find "$WD" -name slang.uhdm | sort)
echo "PREDICTED $hit / $tot databases   (delay_control objects seen in OUR pristine dumps: $alldc; of them intra-assignment-parented and refless: $intradc)"
