#!/bin/bash
# r10uvm47 — the t65* arms of § pkgInitRefBindsOwnListing47, each as a
# GOLDEN-vs-OURS census diff plus a uhdm-cmp verdict.
#
# LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.  uhdm-cmp is invoked as
# (golden.uhdm, ours.uhdm) and never the other way round.
#
# POSITIVE CONTROL: every missing input is FATAL and named, and a cell whose
# golden or ours database is absent sets rc=3 rather than printing a zero diff.
# (Pass 46's `listdirect.sh` printed a closed-looking total under four "census
# missing" lines; a driver that cannot see its subject must not be able to
# report perfection.)
#
#   usage: arms65.sh <tag> [cells...]      default cells: t65a t65c t65d
#          t65b is GOLDEN-ONLY (slang rejects it) and is reported by goldfile.sh
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE"/../../.. && pwd)
TAG=${1:?usage: arms65.sh <tag> [cells...]}
shift
CELLS=${*:-"t65a t65c t65d"}
PROBE=/tmp/r10uvm47_r10uvm47ro
CMP=/home/heyfey/.local/bin/uhdm-cmp
[ -x "$PROBE" ] || { echo "FATAL: no probe at $PROBE (run probebuild.sh r10uvm47ro)"; exit 3; }
[ -x "$CMP" ] || { echo "FATAL: no uhdm-cmp at $CMP"; exit 3; }
rc=0
for C in $CELLS; do
  D=/tmp/r10uvm47_${C}_$TAG
  bash "$HERE/gold.sh" "$C" "$D" > "$D.log" 2>&1
  G=$D/slpp_all/surelog.uhdm
  O=$D/ours.uhdm
  if [ ! -s "$G" ]; then echo "$C FATAL: no golden"; rc=3; continue; fi
  if [ ! -s "$O" ]; then echo "$C FATAL: no ours (slang rejected? see $D.log)"; rc=3; continue; fi
  "$PROBE" "$G" > "/tmp/r10uvm47_arm65_g_$C.txt" 2>&1
  "$PROBE" "$O" > "/tmp/r10uvm47_arm65_${TAG}_$C.txt" 2>&1
  n=$(diff "/tmp/r10uvm47_arm65_g_$C.txt" "/tmp/r10uvm47_arm65_${TAG}_$C.txt" | grep -c '^[<>]')
  "$CMP" "$G" "$O" > "/tmp/r10uvm47_arm65cmp_${TAG}_$C.txt" 2>&1
  v=$?
  echo "$C initcensus_diff=$n cmp=$([ $v -eq 0 ] && echo EQUAL || echo NOTEQUAL) cmpbytes=$(wc -c < "/tmp/r10uvm47_arm65cmp_${TAG}_$C.txt")"
done
exit $rc
