#!/usr/bin/env bash
# r10svs10 CENSUS — the population § classHandleWriteKeepsTs10 can move, read
# from the PRISTINE side ALONE so it is a PREDICTION and not a description of
# the movers the byte verifier later finds.
#
#   usage: ./census.sh <pristine_workdir_root>   [> census.txt]
#
# THE CARRIER SHAPE.  The deleted predicate fired on a DEF-VIEW net that is
#   (a) class-typed, (b) NOT written with a scoped name, (c) procedurally
#   assigned, and (d) not already stripped by the non-ANSI-header rule.
# In a dump that is exactly: a `logic_net` in a definition's listing carrying NO
# `vpiTypespec`, whose ELAB twin (same vpiFullName tail) is a `class_var`.  A
# class_var twin is what proves the net is class-typed even though the def view
# tells us nothing about its type — which is the whole defect.
#
# TRAPS ENCODED:
#   * uhdm-dump's FIRST LINE is the database path -> `sed 1d`, or the census
#     keys on a path that differs between the two roots.
#   * `vpiParent` back-pointers reprint the net INSIDE its own subtree, so a
#     line-oriented count double-counts; the per-net decision is made by
#     ctsread.py, which walks the indent column.
#   * a database that FAILED to build is reported as ABSENT, never as zero
#     carriers -- "no carriers" and "no database" are different findings.
set -u
B=${1:?pristine workdir root}
HERE=$(cd "$(dirname "$0")" && pwd)
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump at $DUMP"; exit 3; }
[ -d "$B" ] || { echo "FATAL: no such root $B"; exit 3; }

total=0; carriers=0; absent=0
while read -r db; do
    rel=${db#"$B"/}
    key=$(dirname "$rel")
    if [ ! -s "$db" ]; then echo "ABSENT   $key"; absent=$((absent+1)); continue; fi
    total=$((total+1))
    # Def-view nets with NO typespec whose elab twin is a class_var.
    n=$("$DUMP" "$db" 2>/dev/null | sed '1d' | python3 "$HERE/ctscensus.py")
    if [ "${n:-0}" -gt 0 ]; then
        echo "CARRIER  $key  nets=$n"
        carriers=$((carriers+1))
    fi
done < <(find "$B" -name slang.uhdm | sort)
echo "---"
echo "databases=$total  CARRIERS=$carriers  absent=$absent"
