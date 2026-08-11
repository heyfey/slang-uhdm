#!/bin/bash
# r10uvm54repro/detcheck.sh — DETERMINISM check for ONE binary on ONE input:
# emit the database N times and compare sha256.
#
# WHY THIS EXISTS.  `classNestedClassTdGroupNoAnchor54` iterates a
# `std::map<const void*, ...>` keyed by a slang SYMBOL POINTER, so the order in
# which its alias `ref_typespec` objects are MINTED — and therefore their UHDM
# ids and the serialized arena order — could in principle vary run to run.  The
# campaign has an open note on emitter nondeterminism (SourceLocation compares
# across macro buffers), so this is measured rather than argued.
#
#   usage: detcheck.sh <bin> <N> <slang args...>
#
# GUARDS: a run that produces NO database is reported as NO_OUTPUT and counted,
# so a check that emitted nothing cannot read as "all identical"; the number of
# DISTINCT hashes is printed, and 1 is the only passing answer.
set -u
BIN=${1:?bin}; N=${2:?runs}; shift 2
[ -x "$BIN" ] || { echo "FATAL: no bin $BIN"; exit 3; }
echo "BIN=$BIN md5=$(md5sum "$BIN" | cut -d' ' -f1)  runs=$N"
T=$(mktemp -d /tmp/r10uvm54_det.XXXXXX)
bad=0
for i in $(seq 1 "$N"); do
  "$BIN" "$@" -o "$T/db$i.uhdm" > "$T/log$i" 2>&1
  if [ ! -f "$T/db$i.uhdm" ]; then
    echo "run $i: NO_OUTPUT"; bad=$((bad+1)); continue
  fi
  echo "run $i: $(sha256sum "$T/db$i.uhdm" | cut -c1-16)  bytes=$(stat -c %s "$T/db$i.uhdm")"
done
D=$(sha256sum "$T"/db*.uhdm 2>/dev/null | cut -d' ' -f1 | sort -u | wc -l)
echo "distinct hashes=$D   NO_OUTPUT runs=$bad   (1 distinct and 0 NO_OUTPUT is the only pass)"
rm -rf "$T"
[ "$D" -eq 1 ] && [ "$bad" -eq 0 ]
