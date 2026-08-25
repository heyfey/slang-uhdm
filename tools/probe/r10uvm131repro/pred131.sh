#!/usr/bin/env bash
# r10uvm131 — A-PRIORI MOVER PREDICTOR.  MEASUREMENT ONLY.
#
# The law touches ONLY named_fork objects (VpiJoinType, span, and the
# EMPTY-fork end-label gate) and the EMPTY unnamed fork_stmt.  A database whose
# PRISTINE dump contains no named_fork and no zero-statement fork_stmt CANNOT
# move.  This walks every slang.uhdm in a verify_golden workdir and prints the
# databases that CAN move, so the mover set is named BEFORE the patch is built.
#
#   CEN=<ct131cen> pred131.sh <workdir> [<workdir> ...]
#
# Every rc is recorded; a database whose census aborts is printed as CEN-FAIL
# and COUNTED (a crash must never read as "cannot move").
set -u
CEN=${CEN:?set CEN=<ct131cen binary>}
tot=0; hit=0; fail=0
for WD in "$@"; do
  while IFS= read -r f; do
    tot=$((tot+1))
    out=$("$CEN" "$f" 2>/dev/null </dev/null); rc=$?
    rel=${f#"$WD"/}; rel=${rel%/slang.uhdm}
    if [ $rc -ne 0 ]; then echo "CEN-FAIL rc=$rc $rel"; fail=$((fail+1)); continue; fi
    nf=$(printf '%s\n' "$out" | grep -c 'KIND=named_fork'); true
    ef=$(printf '%s\n' "$out" | grep -c 'KIND=fork_stmt.*NSTMT=0'); true
    if [ "$nf" -gt 0 ] || [ "$ef" -gt 0 ]; then
      echo "CAN-MOVE named_fork=$nf emptyfork=$ef $rel"; hit=$((hit+1))
    fi
  done < <(find "$WD" -name slang.uhdm | sort)
done
echo "-- scanned=$tot CAN-MOVE=$hit CEN-FAIL=$fail"
