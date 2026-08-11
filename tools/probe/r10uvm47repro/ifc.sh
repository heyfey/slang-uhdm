#!/bin/bash
# r10uvm47 (cloned from pass 46) — the ranked-#1 driver: project golden and ours onto the interface_inst
# OBJECT + CONTAINER-POSITION census (`r10uvm46if`) for one sweep test and diff.
#
# `ifcount.sh` (pass 45) answered "how many"; this answers "where", which is the
# question a missing OBJECT actually poses.  It REFUSES to print a diff count it
# cannot substantiate: both projections must be non-empty and the probe must
# exit 0 (the probe itself refuses on a zero-OBJ file).
#   usage: ifc.sh <sweep-workdir> <test> [mode]
set -u
WD=${1:?}
T=${2:?}
MODE=${3:-default}
V=/tmp/r10uvm47_r10uvm46if
[ -x "$V" ] || { echo "FATAL: probe $V missing"; exit 3; }
D=$(ls -d "$WD/$MODE/$T"-* 2>/dev/null | head -1)
[ -n "$D" ] || { echo "FATAL: $T: no workdir under $WD/$MODE"; exit 3; }
G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[0-9a-f]*" "$D/cmds.txt" | head -1)/golden.uhdm
[ -f "$G" ] || { echo "FATAL: golden $G missing"; exit 3; }
[ -f "$D/slang.uhdm" ] || { echo "FATAL: $D/slang.uhdm missing"; exit 3; }
go=/tmp/r10uvm47_ifc_g_${T}_$MODE.txt
oo=/tmp/r10uvm47_ifc_o_${T}_$MODE.txt
"$V" "$G" > "$go" || { echo "FATAL: probe failed on golden $G"; exit 3; }
"$V" "$D/slang.uhdm" > "$oo" || { echo "FATAL: probe failed on ours"; exit 3; }
for f in "$go" "$oo"; do
  [ -s "$f" ] || { echo "FATAL: $f EMPTY"; exit 3; }
done
echo "== $T/$MODE  golden OBJ=$(grep -c '^OBJ' "$go") ours OBJ=$(grep -c '^OBJ' "$oo")  diff lines=$(diff "$go" "$oo" | grep -c '^[<>]')"
diff "$go" "$oo" | sed -e 's/^</GOLDEN-ONLY /' -e 's/^>/OURS-ONLY   /' | grep -E '^(GOLDEN|OURS)' | cut -c1-190
