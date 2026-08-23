#!/usr/bin/env bash
# r10uvm109repro/goldcen105.sh — CALIBRATE GOLDEN-VS-GOLDEN FIRST (RESUME §9).
# MEASUREMENT ONLY.
#
#   goldcen105.sh <sweep workdir> <cen bin> <out prefix> [name-substring ...]
#
# Surelog's `default` and `testflags` runs of the SAME test are DIFFERENT cache
# entries built from DIFFERENT command lines, so they are two independent
# goldens of one design.  This script censuses both and reports the rows on
# which they DISAGREE.  Every such row is an EXPECTED-MISMATCH the pass's own
# golden-vs-ours numbers must be read against; the calibration is only sound
# when this prints 0.
#
# READ THE NUMBER CORRECTLY.  Over the WHOLE surelog corpus this is NOT expected
# to be 0: for most tests the `testflags` command line is a DIFFERENT DESIGN
# (its own defines, its own file set, its own top), so the two goldens are two
# different databases and 686 of 755 pairs differ.  The calibration that bears
# on this pass is the one over the databases the pass can touch — pass their
# names as extra arguments (SeqDriver SimpleUVM MiniAmiq BuildUVMPkg), where the
# two command lines ARE UHDM-equivalent and the number MUST be 0.
#
# GUARDS: the golden path is read out of each test's own cmds.txt and the cache
# DIRECTORY is turned into .../golden.uhdm (handing the census a directory
# measures nothing); a missing side prints SKIP and is COUNTED; the census's own
# rc is recorded.  The comparison DROPS the tag column (the two runs tag
# themselves differently) and is a sorted multiset.
set -u
WD=${1:?workdir}; CEN=${2:?cen}; OUT=${3:?out prefix}
shift 3 || true
NAMES=("$@")
T=$(mktemp -d /tmp/r10uvm109_goldcen.XXXXXX)
tot=0; skip=0; bad=0
: > "$OUT.report"
for d in "$WD"/default/*/; do
  [ -f "$d/cmds.txt" ] || continue
  t=$(basename "$d"); e="$WD/testflags/$t"
  if [ ${#NAMES[@]} -gt 0 ]; then
    keep=0; for nm in "${NAMES[@]}"; do case "$t" in "$nm"-*) keep=1;; esac; done
    [ "$keep" = 1 ] || continue
  fi
  [ -f "$e/cmds.txt" ] || { echo -e "SKIP\t$t\tno testflags arm" >> "$OUT.report"; skip=$((skip+1)); continue; }
  gd=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
  ge=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$e/cmds.txt" | head -1)
  [ -n "$gd" ] && [ -d "$gd" ] && gd=$gd/golden.uhdm || gd=""
  [ -n "$ge" ] && [ -d "$ge" ] && ge=$ge/golden.uhdm || ge=""
  if [ -z "$gd" ] || [ -z "$ge" ] || [ ! -f "$gd" ] || [ ! -f "$ge" ]; then
    echo -e "SKIP\t$t\tmissing golden" >> "$OUT.report"; skip=$((skip+1)); continue
  fi
  "$CEN" "$gd" D > "$T/d.tsv" 2>/dev/null; rd=$?
  "$CEN" "$ge" E > "$T/e.tsv" 2>/dev/null; re=$?
  if [ $rd -ne 0 ] || [ $re -ne 0 ]; then
    echo -e "CENFAIL\t$t\trc=$rd/$re" >> "$OUT.report"; skip=$((skip+1)); continue
  fi
  n=$(diff <(cut -f2- "$T/d.tsv" | LC_ALL=C sort) <(cut -f2- "$T/e.tsv" | LC_ALL=C sort) | grep -c '^[<>]' || true)
  tot=$((tot+1))
  if [ "$n" != 0 ]; then bad=$((bad+1)); echo -e "DIFFER\t$t\t$n" >> "$OUT.report"; fi
done
rm -rf "$T"
echo "calibrated pairs: $tot   SKIP: $skip   pairs that DIFFER: $bad"
echo "EXPM_N (rows on which golden disagrees with golden): $(awk -F'\t' '$1=="DIFFER"{s+=$3} END{print s+0}' "$OUT.report")"
