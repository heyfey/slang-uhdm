#!/bin/bash
# r11v11u10 — the VERIFIER's break grid for r11u10.
# Usage: vgrid10.sh <slang-uhdm binary> <grid root> [arm...]
# Every arm records surelog rc, our rc, cmp rc, cmp lines and head count; the
# two arms whose golden side does not compile (a `'{default:...}` array
# parameter SEGFAULTS Surelog v1.87, an indexed `'{0:..,1:..}` array pattern is
# rejected rc=4) are NOT in this directory: an arm whose compile fails teaches
# error recovery, not golden.
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
BIN=${1:?slang-uhdm binary}
ROOT=${2:?grid root}
shift 2
ARMS=${*:-$(cd "$ROOT" && ls -d v* 2>/dev/null)}
for a in $ARMS; do
  d="$ROOT/$a"
  [ -f "$d/dut.sv" ] || { echo "=== $a NO-ARM"; continue; }
  (cd "$d" && $SL -parse -nobuiltin -nocache -sv dut.sv > sl.log 2>&1); slrc=$?
  (cd "$d" && "$BIN" dut.sv --single-unit --nobuiltin -o ours.uhdm > ours.log 2>&1); ourc=$?
  $CMP "$d/slpp_all/surelog.uhdm" "$d/ours.uhdm" > "$d/cmp.out" 2> "$d/cmp.err"; cmprc=$?
  $DUMP "$d/slpp_all/surelog.uhdm" > "$d/gold.dump" 2>/dev/null
  $DUMP "$d/ours.uhdm" > "$d/ours.dump" 2>/dev/null
  echo "=== $a surelog_rc=$slrc ours_rc=$ourc cmp_rc=$cmprc cmplines=$(wc -l < "$d/cmp.out") heads=$(grep -c '^LHS:' "$d/cmp.err"; true)"
done
exit 0
