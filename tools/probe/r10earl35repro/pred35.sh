#!/usr/bin/env bash
# r10earl35 — THE SOURCE-DERIVED MOVER FENCE.
#
# Written and run against the PRISTINE dump BEFORE any patched sweep was read.
#
# § pkgStructDeclArrFlat35 makes TWO predicates answer TRUE strictly more
# often than they did:
#
#     old: leaf = declared canonical type;  struct? scan : false
#     new: leaf = declared canonical type with its PACKED-ARRAY dims stripped;
#          struct? scan : false
#
# When the declared canonical type is already a struct the `while` never runs
# and the two are IDENTICAL, so new ⊇ old — the predicates are MONOTONE
# INCREASING.  Both are used only as `... && !PRED(sym)` guarding a single
# `VpiNetType(vpiWire)` assignment, so a monotone increase can only SUPPRESS an
# assignment that used to happen.  Formally, therefore:
#
#   F1. the patch can only ever REMOVE `|vpiNetType:` lines from nets;
#   F2. it can ADD no dump line of any kind, and can change no other field;
#   F3. every removal sits on a net whose declaration writes an EXPLICITLY
#       package-qualified struct type (`isExplicitPkgQualified`) carrying a
#       PACKED-ARRAY dimension, whose struct leaf is NOT flat (a struct field,
#       a packed-array-of-struct field, or an integer / enum / 2-state field).
#
# So the whole predicted mover set is enumerable from the pristine dump alone:
# it is a SUBSET of the nets that print a vpiNetType today.  This script prints
# that superset and the one member the corpus census says is actually wrong.
#
# usage: ./pred35.sh <pristine-dump>        (dump already sed 1d)
set -u
D=${1:?pristine dump (sed 1d)}
[ -f "$D" ] || { echo "FATAL: no such dump $D"; exit 9; }

echo "== F1/F2: the ONLY dump lines the patch may touch =="
echo -n "   nets printing a vpiNetType at all (the mover SUPERSET): "
grep -cE '^\s*\|vpiNetType:' "$D"

echo
echo "== F3: the ONE net the design-wide net-type census says disagrees =="
echo "   (golden: no vpiNetType; ours: vpiNetType:1)"
grep -nE '_net: \(work@flash_mp\.region_cfgs_i\)' "$D" | head -2

echo
echo "PREDICTION"
echo "  ADDED dump lines                     : 0        (F2, formal)"
echo "  REMOVED dump lines not |vpiNetType:  : 0        (F1, formal)"
echo "  net-type census disagreements before : 1        (work@flash_mp.region_cfgs_i)"
echo "  net-type census disagreements after  : 0"
echo "  head                                 : CLEARED"
echo "  every other REMOVED |vpiNetType: line must land on a net golden also"
echo "  leaves untyped — any removal golden TYPES is an OVER-FIRE and fails."
