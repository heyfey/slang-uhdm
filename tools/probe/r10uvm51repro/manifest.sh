#!/bin/bash
# r10uvm51repro/manifest.sh — sha256 every slang.uhdm under a verify_golden
# workdir, path-relative, sorted.  Half of the BYTE VERIFIER: the whole-row CSV
# diff is BLIND inside rows that are already CMP_NOTEQUAL (and inside the 183
# u2r CMP_EQUAL+dump-differ rows), so byte identity of every emitted database is
# proved separately.
#
# This pass runs the verifier BACKWARDS relative to r10uvm48repro/byteverify.sh:
# the POST manifest is taken from the sweeps that ALREADY produced the gate-3 and
# gate-4 CSVs, then the HEAD binary is run into the SAME workdir paths and its
# manifest taken.  Same comparison, two fewer full sweeps.  The workdir path is
# part of what is compared, so both halves MUST use the same path.
#
#   usage: manifest.sh <workdir> <outfile>
#
# GUARD (measure the measurer): a manifest with zero databases is a hard error —
# an empty manifest joined against an empty manifest reports "0 differ", which is
# precisely the failure that reads as perfection.
set -u
WD=${1:?workdir}
OUT=${2:?outfile}
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
find "$WD" -name slang.uhdm -type f -printf '%P\n' | sort | while read -r p; do
  printf '%s  %s\n' "$(sha256sum "$WD/$p" | cut -d' ' -f1)" "$p"
done > "$OUT"
N=$(wc -l < "$OUT")
echo "manifest $OUT databases=$N"
[ "$N" -gt 0 ] || { echo "REFUSING TO REPORT: manifest is EMPTY"; exit 5; }
