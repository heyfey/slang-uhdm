#!/usr/bin/env bash
# r10uvm118 — A-PRIORI MOVER PREDICTION + corpus census, read out of PRISTINE
# databases only (no patched binary is involved).
#
# For every database in a verify_golden workdir it runs ct118cen twice — on OUR
# pristine .uhdm and on the GOLDEN the workdir's own cmds.txt names — and prints
#
#   <mode> <test> FAM_OURS=<n> FAM_GOLD=<n> OURS[...] GOLD[...]
#
# FAM_ = the family cell count: a BARE cast whose PARENT is a CONCATENATION
# (vpiConcatOp, 33) — slang inserts the string conversion ONLY on concat
# operands, so that parent is part of the fingerprint.
#
# `BARE` is this pass's family fingerprint: an operation(vpiCastOp) whose
# Actual_typespec is a LOC-LESS, NAMELESS logic_typespec — the shape our
# Conversion arm's catch-all mints for slang's compiler-inserted string-concat
# operand wrap.  Golden's count is 0 everywhere by construction (Surelog mints
# vpiCastOp ONLY from a written `'`), so ours_BARE > 0 predicts a mover BY NAME.
#
# The golden path is read from the workdir's OWN cmds.txt (never guessed) and
# the cache DIRECTORY is turned into .../golden.uhdm; a missing side prints
# SKIP-NOFILE and is counted, because a driver that reaches nothing must never
# read as perfection.
#
# usage: pred118.sh <workdir> <ct118cen> [mode ...]
set -u
WD=${1:?workdir}; CEN=${2:?ct118cen}
shift 2
MODES=${*:-"default testflags"}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
miss=0; done=0
for mode in $MODES; do
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    n=$(basename "$d"); n=${n%-*}
    O=$d/slang.uhdm; C=$d/cmds.txt; G=""
    [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    if [ ! -f "$O" ] || [ -z "$G" ] || [ ! -f "$G" ]; then
      printf "%-9s %-28s SKIP-NOFILE\n" "$mode" "$n"; miss=$((miss+1)); continue
    fi
    os=$("$CEN" "$O" --cast 2>/tmp/r10uvm118_pred.$$.e >/tmp/r10uvm118_pred.$$.o; sed -n 's/^-- //p' /tmp/r10uvm118_pred.$$.e)
    ob=$(grep -c 'PAR=operation:33.*TS=logic_typespec.*TSLOC=0.*TSNAME=-' /tmp/r10uvm118_pred.$$.o; true)
    gs=$("$CEN" "$G" --cast 2>/tmp/r10uvm118_pred.$$.e >/tmp/r10uvm118_pred.$$.o; sed -n 's/^-- //p' /tmp/r10uvm118_pred.$$.e)
    gb=$(grep -c 'PAR=operation:33.*TS=logic_typespec.*TSLOC=0.*TSNAME=-' /tmp/r10uvm118_pred.$$.o; true)
    printf "%-9s %-28s FAM_OURS=%s FAM_GOLD=%s OURS[%s] GOLD[%s]\n" "$mode" "$n" "$ob" "$gb" "${os:-RESTORE_FAILED}" "${gs:-RESTORE_FAILED}"
    done=$((done+1))
  done
done
echo "-- measured=$done SKIP-NOFILE=$miss"
