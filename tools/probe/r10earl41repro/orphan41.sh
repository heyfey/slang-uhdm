#!/usr/bin/env bash
# r10earl41 F4 verifier — the ORPHAN probe, measured in BYTES.
#
#   usage: SLANG_UHDM=/abs/build/slang-uhdm ./orphan41.sh <outdir>
#
# Emits, for the probe AND for a whitespace-free CONTROL that never abstains:
#   * the .uhdm file SIZE (the only instrument that sees an unreachable object)
#   * the md5 of the `sed 1d`-ed uhdm-dump (which must NOT change: the orphans
#     are unreachable, so no walk prints them)
# Ops traps: SLANG_UHDM has no default and its md5 is printed; uhdm-dump's
# first line is the database path and always differs -> sed 1d.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
D=${1:?outdir}
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
[ -x "$SLANG_UHDM" ] || { echo "FATAL: no such binary $SLANG_UHDM"; exit 9; }
[ -x "$DUMP" ] || { echo "FATAL: no such tool $DUMP"; exit 9; }
echo "BINARY $SLANG_UHDM md5=$(md5sum "$SLANG_UHDM" | cut -d' ' -f1)"
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$HERE/v41_orphan.sv" "$D/" || exit 9
# The CONTROL is the same module with a SIMPLE range, which the builder can
# build: it never abstains, so its size is the "no orphan" reference point.
sed 's/DW-1 -: 4/DW-1:4/; s/v41_orphan/v41_ctrl/' "$HERE/v41_orphan.sv" \
    > "$D/v41_ctrl.sv"
# THE ISOLATING CASE.  v41_orphan carries a PACKAGE-QUALIFIED base, so this
# pass's OTHER change (§ pkgWrittenQualSelBase41) also touches it and its dump
# is allowed to move.  v41_bare drives the SAME abstention through a LOCAL
# array base, which no part of the naming law can reach, so ITS dump must be
# BYTE-IDENTICAL across the two binaries while its file SHRINKS.  That is the
# clean F4 proof; the qualified probe only supplies the headline number.
sed 's/r41::A/loc/; s/v41_orphan/v41_bare/' "$HERE/v41_orphan.sv" \
  | sed 's/^  for (genvar/  logic [3:0][7:0] loc;\n  assign loc = r41::A;\n  for (genvar/' \
    > "$D/v41_bare.sv"
cd "$D" || exit 9
for t in v41_orphan v41_ctrl v41_bare; do
  "$SLANG_UHDM" "$t.sv" -o "$t.uhdm" > "$t.log" 2>&1
  [ -f "$t.uhdm" ] || { echo "NO_OUTPUT $t"; tail -5 "$t.log"; exit 6; }
  "$DUMP" "$t.uhdm" 2>/dev/null | sed '1d' > "$t.dump"
  echo "$t bytes=$(stat -c%s "$t.uhdm") dumplines=$(wc -l < "$t.dump") dumpmd5=$(md5sum "$t.dump" | cut -d' ' -f1)"
done
echo "WD=$D"
