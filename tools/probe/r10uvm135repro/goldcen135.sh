#!/usr/bin/env bash
# r10uvm135repro/goldcen135.sh — GOLDEN-VS-GOLDEN CALIBRATION, run FIRST.
# MEASUREMENT ONLY.  `default` and `testflags` are two independent Surelog runs
# of the same design; this family's rows must be identical in both, or every
# golden-vs-ours number below is read against an unknown expected mismatch.
#   goldcen135.sh <sweep workdir> <ct135cen> <name> [...]
set -u
WD=${1:?workdir}; CEN=${2:?ct135cen}; shift 2
T=$(mktemp -d /tmp/r10uvm135_gc.XXXXXX)
pairs=0; skip=0; diffn=0; rows=0
for n in "$@"; do
  gg=()
  for mode in default testflags; do
    for d in "$WD/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" 2>/dev/null | head -1)
      [ -n "$G" ] && [ -f "$G/golden.uhdm" ] && gg+=("$G/golden.uhdm")
    done
  done
  if [ "${#gg[@]}" -lt 2 ]; then echo "$n SKIP (only ${#gg[@]} golden)"; skip=$((skip+1)); continue; fi
  pairs=$((pairs+1))
  "$CEN" "${gg[0]}" G | grep -P "\t(${FAM:-NET|AIDX})\t" | cut -f2- | LC_ALL=C sort > "$T/a"
  "$CEN" "${gg[1]}" G | grep -P "\t(${FAM:-NET|AIDX})\t" | cut -f2- | LC_ALL=C sort > "$T/b"
  r=$(wc -l < "$T/a"); rows=$((rows+r))
  if cmp -s "$T/a" "$T/b"; then echo "$n CALIBRATED rows=$r"
  else echo "$n DIFFERS rows=$r"; diffn=$((diffn+1)); diff "$T/a" "$T/b" | head -20; fi
done
echo "-- pairs=$pairs SKIP=$skip DIFFER=$diffn rows=$rows  EXPM_N=$diffn"
rm -rf "$T"
