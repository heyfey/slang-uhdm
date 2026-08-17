#!/usr/bin/env bash
# r10buvm9repro/headset9.sh — the SEVEN-ROW HEAD SET, pristine vs patched, with
# rowheads.sh doing the measuring (it carries the traps: uhdm-cmp exits 0 on a
# missing input, heads are `grep -c '^LHS:'` anchored at column 0, the golden
# path is read out of each workdir's own cmds.txt).  MiniAmiq is in the list per
# the brief; it is SLANG_REJECT on both binaries and therefore prints
# SKIP-NOFILE, which is COUNTED, not hidden.
#
#   usage: headset9.sh <patched_wd> <pristine_wd> <outdir>
set -u
A=${1:?patched workdir}
B=${2:?pristine workdir}
O=${3:?outdir}
D=$(cd "$(dirname "$0")" && pwd)
NAMES="BuildUVMPkg SimpleUVM SeqDriver Scoreboard Earlgrey_0_1 YosysVerx MiniAmiq"
echo "===== PRISTINE $B"
"$D/rowheads.sh" "$B" "$O/pris" $NAMES
echo "===== PATCHED  $A"
"$D/rowheads.sh" "$A" "$O/pat" $NAMES
echo "===== cmp-LOG BYTE comparison (the only wall measurement that means"
echo "      anything once a row's database moves)"
for n in $NAMES; do for m in default testflags; do
  p=$O/pris/$n.$m.cmp; q=$O/pat/$n.$m.cmp
  if [ -f "$p" ] && [ -f "$q" ]; then
    if cmp -s "$p" "$q"; then printf "  %-14s %-9s %8s lines  BYTE-IDENTICAL\n" "$n" "$m" "$(wc -l < "$p")"
    else printf "  %-14s %-9s %8s -> %-8s lines  CHANGED\n" "$n" "$m" "$(wc -l < "$p")" "$(wc -l < "$q")"; fi
  else printf "  %-14s %-9s  (one or both cmp logs absent -- COUNTED, not hidden)\n" "$n" "$m"; fi
done; done
