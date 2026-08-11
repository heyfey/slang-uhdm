#!/usr/bin/env bash
# vmints.sh -- COUNT THE MINT SITES.  For one workdir cell, diff OUR pristine
# dump against OUR patched dump (both sides ours -- this is NOT a golden
# comparison) and count what each law added or replaced.
#
#   usage: ./vmints.sh <relative-cell-path e.g. default/SVSwitch-db796243>
#          with R10OTH6_PATCHED_WD / R10OTH6_PRISTINE_WD pointing at the two
#          sweep workdir roots.
#
# uhdm-dump's FIRST LINE IS THE DATABASE PATH and always differs -> `sed 1d`.
# A cell that cannot be resolved prints UNMEASURED rather than 0.
set -u
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
A=${R10OTH6_PATCHED_WD:?set R10OTH6_PATCHED_WD}
B=${R10OTH6_PRISTINE_WD:?set R10OTH6_PRISTINE_WD}
C=$1
pa="$A/$C/slang.uhdm"; pb="$B/$C/slang.uhdm"
if [ ! -f "$pa" ] || [ ! -f "$pb" ]; then
  echo "$C: UNMEASURED(no database: patched=$pa pristine=$pb)"; exit 3
fi
t=$(mktemp -d)
"$DUMP" "$pb" 2>/dev/null | sed 1d > "$t/pristine.dump"
"$DUMP" "$pa" 2>/dev/null | sed 1d > "$t/patched.dump"
if [ ! -s "$t/pristine.dump" ] || [ ! -s "$t/patched.dump" ]; then
  echo "$C: UNMEASURED(empty dump)"; rm -rf "$t"; exit 3
fi
diff -u "$t/pristine.dump" "$t/patched.dump" > "$t/d" || true
# § virtualIfacePropIsBareLogicVar6: a class-scoped `logic_var` ADDED.
p=$(grep -cE '^\+ *\\_logic_var: \([A-Za-z_@][^)]*::[^):]*\)' "$t/d")
# § classDefnVirtualFromVirtualIfaceDecl6: a `vpiVirtual:1` ADDED.
v=$(grep -cE '^\+ *\|vpiVirtual:1' "$t/d")
# § virtualIfaceTsIsInterfaceTs6: an `interface_typespec` ADDED (and the
# matching `logic_typespec` REMOVED).
i=$(grep -cE '^\+ *\\_interface_typespec:' "$t/d")
l=$(grep -cE '^\- *\\_logic_typespec:' "$t/d")
# NOTE, added by the r10oth6 VERIFIER: $i and $l count dump LINES, and every
# typespec object is printed TWICE (once nested as a ref_typespec's vpiActual,
# once in the flat typespec listing).  So `interface_typespec+=10` on SVSwitch
# is FIVE OBJECTS.  The write-ups quote the object count; this tool quotes the
# line count; they are the same measurement.  The label says so now.
# The `dump lines` figure had the same +2 bug viarm.sh had -- `grep -c '^[-+]'`
# counts diff -u's own ---/+++ header.  Fixed here too.
echo "$C: logic_var+=$p vpiVirtual+=$v interface_typespec_LINES+=$i (=$((i / 2)) objects) logic_typespec_LINES-=$l  (dump lines +/- $(grep -E '^[-+]' "$t/d" | grep -vcE '^(---|\+\+\+) '))"
rm -rf "$t"
