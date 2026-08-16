#!/bin/bash
# r10uvm75repro/rowheads.sh — cmp lines / head count for a NAMED SUBSET of a
# verify_golden workdir.  `heads.sh` walks the WHOLE workdir, which costs one
# uhdm-cmp per test (953 of them on the surelog corpus); this one takes the names
# so the seven target rows can be re-measured in seconds.
#
# LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.
#
#   usage: rowheads.sh <workdir> <outdir> <name> [<name> ...]
#
# GUARDS (each an ops trap this campaign has paid for):
#   * uhdm-cmp EXITS 0 WHEN AN INPUT FILE IS MISSING, so BOTH sides are
#     existence-checked and a missing side prints SKIP-NOFILE and is COUNTED —
#     a driver that reaches nothing must never read as perfection.
#   * heads are counted with `grep -c '^LHS:'` anchored at column 0, because cmp
#     prints `decompile:` twice per side for ONE head.
#   * the golden path is read out of the workdir's own cmds.txt, so this script
#     cannot silently compare against the wrong golden, and the cache DIRECTORY
#     is turned into .../golden.uhdm (handing uhdm-cmp a directory compares
#     nothing).
#   * a NAME that matches no directory in either mode is printed as UNKNOWN-NAME
#     and counted.
set -u
WD=${1:?workdir}
OUT=${2:?outdir}
shift 2
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
[ -x "$CMP" ] || { echo "FATAL: no uhdm-cmp at $CMP"; exit 3; }
mkdir -p "$OUT" || exit 1
miss=0; unk=0; found=0
printf "%-14s %-9s %8s %6s %s\n" TEST MODE CMPLINES HEADS NOTE
for n in "$@"; do
  seen=0
  for mode in default testflags; do
    for d in "$WD/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      seen=1
      O=$d/slang.uhdm
      C=$d/cmds.txt
      G=""
      [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
        printf "%-14s %-9s %8s %6s %s\n" "$n" "$mode" - - "SKIP-NOFILE(g=${G:-none})"
        miss=$((miss+1)); continue
      fi
      F=$OUT/$n.$mode.cmp
      "$CMP" "$G" "$O" > "$F" 2>&1
      # CAPTURE cmp's OWN status here: reading $? inside the printf below picks
      # up the last command substitution instead and printed rc=0 for a cmp that
      # had exited 255.  DO NOT LEAVE A NUMBER IN AN INSTRUMENT THAT THE
      # INSTRUMENT DID NOT MEASURE.
      crc=$?
      printf "%-14s %-9s %8s %6s %s\n" "$n" "$mode" \
        "$(wc -l < "$F")" "$(grep -c '^LHS:' "$F")" "cmp rc=$crc"
      found=$((found+1))
    done
  done
  if [ "$seen" -eq 0 ]; then
    printf "%-14s %-9s %8s %6s %s\n" "$n" - - - UNKNOWN-NAME
    unk=$((unk+1))
  fi
done
echo "-- measured=$found  SKIP-NOFILE=$miss  UNKNOWN-NAME=$unk"
