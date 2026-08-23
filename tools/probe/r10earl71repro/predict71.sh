#!/usr/bin/env bash
# r10earl71 — PREDICT the mover set from the PRISTINE databases alone.
# A candidate is an ELAB port High_conn plain part_select BOUND (path exactly
# HC/l or HC/r, i.e. a DIRECT bound) that our PRISTINE database emits as a
# CONSTANT inside a chain that contains a gen_scope, AND whose GOLDEN twin is a
# ref_obj bound to an enum_const.  MEASUREMENT ONLY.
#   usage: predict71.sh <sweep-workdir> <tscen71>
set -u
WD=${1:?workdir}; CEN=${2:?tscen71}
for db in $(find "$WD" -name slang.uhdm | sort); do
  d=$(dirname "$db")
  g=$(sed -n 's/.*golden cache hit \(.*\))/\1/p' "$d/cmds.txt" 2>/dev/null)/golden.uhdm
  [ -f "$g" ] || continue
  cand=$(R66_INST=1 "$CEN" "$db" 2>/dev/null \
        | grep -E ' HC/(l|r) constant ' | grep 'gen_scope' | grep -c '' ; true)
  [ "${cand:-0}" = 0 ] && continue
  gref=$(R66_INST=1 "$CEN" "$g" 2>/dev/null \
        | grep -E ' HC/(l|r) ref_obj ' | grep 'gen_scope' | grep -c 'actual=enum_const' ; true)
  echo "CAND $cand GOLDREF ${gref:-0} ${d#$WD/}"
done
