#!/usr/bin/env bash
# r10uvm92 — MOVER ATTRIBUTION.  For each byte-mover, the uhdm-dump DELTA of
# the patched vs the pristine database, classified by LINE KIND.
# § hpIdxOpPrettyPrint92 rewrites TEXT ONLY -- the NAME of a hier_path and the
# fullnames of the path elements underneath it -- so a clean attribution shows
# ONLY `hier_path`, `bit_select`, `part_select`, `indexed_part_select`,
# `|vpiName` and `|vpiFullName` lines, and INSERTIONS MUST EQUAL DELETIONS
# (no object is created or destroyed).  Anything else is a line this pass did
# not predict and must be READ, not summarised.
#   usage: attr92.sh <patched wd> <pristine wd> <relpath> [relpath...]
set -u
A=${1:?}; B=${2:?}; shift 2
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
for p in "$@"; do
  "$DUMP" "$A/$p" 2>/dev/null | sed 1d > /tmp/r10uvm92_attr_pat.dump
  "$DUMP" "$B/$p" 2>/dev/null | sed 1d > /tmp/r10uvm92_attr_pris.dump
  n=$(diff /tmp/r10uvm92_attr_pris.dump /tmp/r10uvm92_attr_pat.dump | grep -cE '^[<>]'; true)
  echo "==== $p : $n delta lines (POSITIONAL)"
  diff /tmp/r10uvm92_attr_pris.dump /tmp/r10uvm92_attr_pat.dump | grep -E '^[<>]' |
    sed -E 's/^([<>]) +/\1 /; s/(\\_[a-z_]+):.*/\1/; s/\|(vpi[A-Za-z]+):.*/|\1/' |
    sort | uniq -c | sort -rn
  # THE MOVER RULE: attribute ONLY order-blind.  A positional diff also reports
  # every PERMUTATION -- on SeqDriver the two typespecs `uvm_reg_addr_t` and
  # `uvm_reg_data_t` simply SWAP places, which is emitter ORDER and not this
  # law.  Sorting both sides first removes every permutation and leaves only
  # lines whose TEXT really changed.
  echo "---- $p : ORDER-BLIND (the authoritative reading)"
  diff <(sort /tmp/r10uvm92_attr_pris.dump) <(sort /tmp/r10uvm92_attr_pat.dump) |
    grep -E '^[<>]' |
    sed -E 's/^([<>]) +/\1 /; s/(\\_[a-z_]+):.*/\1/; s/\|(vpi[A-Za-z]+):.*/|\1/' |
    sort | uniq -c | sort -rn
done
