#!/usr/bin/env bash
# r10oth7 — MINT-SITE COUNTER.  "A fix that reaches nothing measures zero and
# reads as a refutation": this is the proof the code ran, and the count of the
# sites it ran at.
#
#   usage: ctmints.sh <ours-pristine.uhdm> <ours-patched.uhdm> <tag>
#
# BOTH SIDES ARE OURS.  This is NOT a golden comparison -- it diffs our own
# pristine dump against our own patched dump, so every reported delta is a byte
# this pass moved and nothing else.
#
# It reports, per law:
#   law A  vpiClassDefn edges ADDED on class_typespec objects
#   law B  vpiName fields ADDED on class_typespec objects
# and it reports them as OBJECT counts taken from the `\_weaklyReferenced:`
# DEFINITION listing, NOT as dump LINE counts -- the r10oth6 V5 defect was
# quoting a line count where the write-up quoted objects.  Both are printed and
# both are labelled.
#
# uhdm-dump's FIRST LINE IS THE DATABASE PATH: stripped on both sides.
# A cell this script cannot resolve prints UNMEASURED and exits 3.
set -u
P=${1:?ours pristine uhdm}
Q=${2:?ours patched uhdm}
TAG=${3:-t}
UD=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -f "$P" ] || { echo "FATAL: missing $P"; exit 9; }
[ -f "$Q" ] || { echo "FATAL: missing $Q"; exit 9; }
D=${OUTDIR:-/tmp/r10oth7_m_$TAG}
mkdir -p "$D" || exit 9
"$UD" "$P" 2>/dev/null | sed '1d' > "$D/pre.dump"
"$UD" "$Q" 2>/dev/null | sed '1d' > "$D/post.dump"
[ -s "$D/pre.dump" ] && [ -s "$D/post.dump" ] || { echo UNMEASURED; exit 3; }
HERE=$(cd "$(dirname "$0")" && pwd)
pre=$(bash "$HERE/ctcount.sh" "$D/pre.dump" "$D/pre.dump" | head -1)
post=$(bash "$HERE/ctcount.sh" "$D/post.dump" "$D/post.dump" | head -1)
[ -n "$pre" ] && [ -n "$post" ] || { echo UNMEASURED; exit 3; }
echo "$TAG PRE  (ours, pristine): ${pre#*: }"
echo "$TAG POST (ours, patched ): ${post#*: }"
diff -u "$D/pre.dump" "$D/post.dump" > "$D/d.diff"
lines=$(grep -E '^[-+]' "$D/d.diff" | grep -vcE '^(---|\+\+\+) ')
echo "$TAG own-vs-own dump delta: $lines LINES (content; diff's own --- / +++ header excluded)"
echo "$TAG   + vpiClassDefn LINES: $(grep -c '^+.*|vpiClassDefn:' "$D/d.diff" || true)"
echo "$TAG   + vpiName LINES     : $(grep -c '^+.*|vpiName:' "$D/d.diff" || true)"
echo "$TAG wd=$D"
