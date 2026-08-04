#!/bin/bash
# r10imex — purpose-built golden runner.
#   run.sh <t>            folded (default mode)
#   run.sh <t> -elabuhdm  elaborated (testflags mode)
# Produces $O/gold.txt and $O/ours.txt and diffs them.
set -u
R=$(cd "$(dirname "$0")" && pwd)
T=$1; shift
EL=""
SEL=""
for a in "$@"; do
  if [ "$a" = "-elabuhdm" ]; then EL="-elabuhdm"; SEL="--elabuhdm"; fi
done
O=${OUT:-/tmp/r10imex_r}/$T${EL:+_e}
rm -rf "$O"; mkdir -p "$O"
cp "$R/$T.sv" "$O/$T.sv"
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog   # the PINNED golden binary
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
SU=${SLANG_UHDM:?set SLANG_UHDM}
(cd "$O" && "$SL" -parse -mt 0 -mp 0 -d uhdm $EL "$T.sv" > sl.log 2>&1)
"$D" "$O/slpp_all/surelog.uhdm" 2>/dev/null | tail -n +2 > "$O/gold.txt"
(cd "$O" && "$SU" $SEL "$T.sv" --single-unit -o ours.uhdm > su.log 2>&1)
"$D" "$O/ours.uhdm" 2>/dev/null | tail -n +2 > "$O/ours.txt"
diff "$O/gold.txt" "$O/ours.txt" > "$O/d.diff"
echo "$T$EL: gold=$(wc -l < "$O/gold.txt") ours=$(wc -l < "$O/ours.txt") diff=$(grep -c '^[<>]' "$O/d.diff")"
