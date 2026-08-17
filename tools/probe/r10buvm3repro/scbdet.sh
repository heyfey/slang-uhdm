#!/usr/bin/env bash
# r10buvm3 — the Scoreboard NONDETERMINISM control.
#
# The second patched sweep reported a THIRD byte mover, `Scoreboard/default`,
# that the FIRST patched sweep did not.  The two patched binaries are provably
# behaviourally identical (347 sd-family cells + the whole uvm_pkg.sv database
# compare byte-identical between them), so the mover is either a real
# order-dependent effect of the patch or the campaign's KNOWN emitter
# nondeterminism (`SourceLocation` compares across macro buffers flip per run
# under parallel parse).  This script decides it the only way that settles it:
# run the SAME command line N times with ONE binary and count distinct hashes.
# If the PRISTINE binary alone produces more than one hash, the mover cannot be
# attributed to the patch.
#
#   usage: scbdet.sh <bin> <N>
set -u
BIN=${1:?bin}; N=${2:-6}
[ -x "$BIN" ] || { echo "FATAL: no bin $BIN"; exit 3; }
SRC=$HOME/git-repos/Surelog/third_party/tests/Scoreboard
UVM=$HOME/git-repos/Surelog/third_party/UVM
D=$(mktemp -d /tmp/r10buvm3_scb.XXXXXX)
cp "$SRC"/design.sv "$SRC"/testbench.sv "$D"/ 2>/dev/null || { echo "FATAL: no Scoreboard sources under $SRC"; exit 3; }
cd "$D" || exit 3
echo "BIN=$BIN md5=$(md5sum "$BIN" | cut -d' ' -f1) runs=$N"
for i in $(seq 1 "$N"); do
  "$BIN" "+incdir+.+$UVM/uvm-1.2/src/+$UVM/svunit_base" \
      "$UVM/uvm-1.2/src/uvm_pkg.sv" "$UVM/svunit_base/svunit_pkg.sv" \
      design.sv testbench.sv --single-unit -o "db$i.uhdm" > "log$i" 2>&1
  if [ ! -f "db$i.uhdm" ]; then echo "run $i: NO_OUTPUT"; continue; fi
  echo "run $i: $(md5sum "db$i.uhdm" | cut -c1-12)"
done
echo "distinct hashes: $(md5sum "$D"/db*.uhdm 2>/dev/null | cut -d' ' -f1 | sort -u | wc -l)"
md5sum "$D"/db*.uhdm 2>/dev/null | cut -d' ' -f1 | sort | uniq -c
rm -rf "$D"
