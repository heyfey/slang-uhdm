#!/usr/bin/env bash
# r10oth7 — print one side's `\_weaklyReferenced:` class_typespec DEFINITIONS
# with their own fields, one block per object.  This is the ONLY place uhdm-dump
# prints a typespec's vpiName / vpiClassDefn; every other appearance is a
# vpiActual back-reference that prints the header line alone.
#
#   usage: ctweak.sh <dump-with-line-1-already-stripped>
#
# REFUSES a dump that still carries uhdm-dump's database-path line 1.
#
# FOR READING, NOT FOR COUNTING.  `grep -A4` cuts each block at four lines and
# also matches INDENTED reference appearances, so a `vpiParent` sub-block hides
# the `vpiClassDefn` that follows it.  Post-processing this output to COUNT
# objects reported ~150 NAME_ONLY class_typespecs on BuildUVMPkg where ctcount.sh
# (which scans indent-0 blocks to their real end) correctly reports 2.  Use
# ctcount.sh for every number; use this to look at the objects.
set -u
F=${1:?dump}
[ -f "$F" ] || { echo "FATAL: missing $F"; exit 9; }
# The guard's first draft matched '\.uhdm$' and never fired: uhdm-dump's line 1
# is `<path>.uhdm: Restored design Pre-Elab:`, so the path is not at the end.
head -1 "$F" | grep -qE '\.uhdm:|Restored design' && {
  echo "REFUSED: $F still has uhdm-dump's database-path line 1 (sed 1d it)"; exit 8; }
L=$(grep -n '^\\_weaklyReferenced:' "$F" | head -1 | cut -d: -f1)
[ -n "$L" ] || { echo "UNMEASURED: no \\_weaklyReferenced: section in $F"; exit 3; }
tail -n "+$L" "$F" | grep -A4 '^\\_class_typespec'
