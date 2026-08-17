#!/bin/bash
# r10ladder1/comparescope.sh — WHAT THE JUDGE ACTUALLY COMPARES.
#
# Half the campaign's residue ledger is about fullnames and spans.  Before any
# of it is scheduled against a CMP_NOTEQUAL row, this prints — from UHDM's own
# generated `<kind>::Compare` bodies, not from memory — how many of those bodies
# reference each location/name property.  A count of ZERO means that property
# CANNOT cause a CMP_NOTEQUAL and the residue belongs to the dump axis instead.
#
#   usage: comparescope.sh [<uhdm-generated-src-dir>]
#
# GUARD: if the source directory yields no Compare bodies at all, every count is
# trivially zero and the output would read as a sweeping law — so the number of
# Compare bodies found is printed FIRST and a zero there is a hard error.
set -u
GEN=${1:-$HOME/git-repos/UHDM/build/generated/src}
[ -d "$GEN" ] || { echo "FATAL: no generated src dir $GEN"; exit 3; }
bodies=0
for f in "$GEN"/*.cpp; do
  awk '/::Compare\(/{p=1} p{print} p&&/^}/{p=0}' "$f"
done > /tmp/.r10ladder1_scope.$$
bodies=$(grep -c '::Compare(' /tmp/.r10ladder1_scope.$$)
echo "Compare bodies found: $bodies"
if [ "$bodies" -eq 0 ]; then rm -f /tmp/.r10ladder1_scope.$$; echo "FATAL: none"; exit 4; fi
for p in VpiFullName VpiFile VpiLineNo VpiColumnNo VpiEndLineNo VpiEndColumnNo \
         VpiName VpiDefName VpiDecompile VpiType VpiAutomatic Instance; do
  printf "  %-16s %6d\n" "$p" "$(grep -c "$p" /tmp/.r10ladder1_scope.$$)"
done
rm -f /tmp/.r10ladder1_scope.$$
