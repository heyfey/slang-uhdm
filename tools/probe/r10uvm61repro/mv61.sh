#!/usr/bin/env bash
# r10uvm61repro/mv61.sh — MOVERS PER SHAPE, vs GOLDEN, BY MULTISET.
#
# For every mover named on the command line (TEST MODE pairs), dump golden,
# pristine-ours and patched-ours, and report
#   * the multiset distance to GOLDEN, pristine -> patched (must IMPROVE)
#   * ADDED and REMOVED line instances SEPARATELY (pristine -> patched)
#   * and, for each, how many of those instances are NOT attributable to a
#     $bits fold -- the number that must be 0 for "the patch changed only what
#     it was written to change" to be a measurement rather than a claim.
#
#   usage: mv61.sh <pat-workdir> <pris-workdir> <outdir> <TEST> <MODE> [...]
#
# GUARDS, each an ops trap this campaign has paid for:
#   * uhdm-dump's FIRST LINE is the DATABASE PATH and always differs; every
#     dump goes through `sed 1d`.  The .uhdm binaries are NEVER compared here.
#   * the golden path is read from the test's OWN cmds.txt and the cache
#     DIRECTORY is turned into .../golden.uhdm; a missing golden prints
#     GOLDEN_MISSING and is COUNTED, never silently skipped.
#   * object ids are stripped before the multiset is taken: they are arena
#     ordinals, they shift whenever the object count changes, and leaving them
#     in makes every line downstream of a fold read as a mover.
#   * a run that examines ZERO movers is a hard error (exit 5): an empty run
#     reads exactly like a clean one.
set -u
PAT=${1:?patched workdir}; PRIS=${2:?pristine workdir}; OUT=${3:?outdir}
shift 3
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
HERE=$(cd "$(dirname "$0")" && pwd)
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump at $DUMP"; exit 3; }
mkdir -p "$OUT" || exit 1

# A dump line is attributable to a $bits fold when it is one of: the sys call
# itself, the argument edge/parent edge it hung on, the argument ref's own
# lines, or the replacement constant's four fields.
FOLDRE='vpiName:[$]bits|sys_func_call: [(][$]bits[)]|vpiArgument:|vpiParent:|vpiSize:64|vpiConstType:9|[|]UINT:[0-9]+|vpiDecompile:[0-9]+|\\_ref_obj:|\\_bit_select:|\\_constant: ,|vpiFullName:|vpiName:[A-Za-z_]|method_func_call|\\_operation:|\\_function: |vpiStmt:|vpiElseStmt:|vpiCondition:|vpiOperand:|vpiIndex:|\\_begin:|\\_if_else:|\\_assignment:|\\_ref_var:|\\_sys_func_call:'

n=0; miss=0
printf '%-14s %-10s | %-28s | %8s %8s | %s\n' TEST MODE "msdist to GOLDEN pris->pat" ADDED REMOVED UNATTRIB
while [ $# -gt 1 ]; do
  T=$1; M=$2; shift 2
  d_pat=$(find "$PAT/$M" -maxdepth 1 -type d -name "$T-*" | head -1)
  d_pri=$(find "$PRIS/$M" -maxdepth 1 -type d -name "$T-*" | head -1)
  if [ -z "$d_pat" ] || [ -z "$d_pri" ] ||
     [ ! -f "$d_pat/slang.uhdm" ] || [ ! -f "$d_pri/slang.uhdm" ]; then
    printf '%-14s %-10s | SKIP-NOFILE\n' "$T" "$M"; miss=$((miss+1)); continue
  fi
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d_pat/cmds.txt" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ]; then
    printf '%-14s %-10s | GOLDEN_MISSING\n' "$T" "$M"; miss=$((miss+1)); continue
  fi
  b=$OUT/$T.$M
  # REUSE=1 skips re-dumping when the three dumps are already present; the
  # dumps are large and deterministic, and a re-parse must not cost 12 minutes.
  if [ "${REUSE:-0}" != 1 ] || [ ! -s "$b.g" ] || [ ! -s "$b.pris" ] || [ ! -s "$b.pat" ]; then
    "$DUMP" "$G"                 | sed '1d' | sed 's/, id:[0-9]*//g; s/id:[0-9]*//g' > "$b.g"
    "$DUMP" "$d_pri/slang.uhdm"  | sed '1d' | sed 's/, id:[0-9]*//g; s/id:[0-9]*//g' > "$b.pris"
    "$DUMP" "$d_pat/slang.uhdm"  | sed '1d' | sed 's/, id:[0-9]*//g; s/id:[0-9]*//g' > "$b.pat"
  fi
  dp=$("$HERE/msdist.sh" "$b.g" "$b.pris" | grep "MULTISET DISTANCE" | sed "s/.*: //")
  df=$("$HERE/msdist.sh" "$b.g" "$b.pat"  | grep "MULTISET DISTANCE" | sed "s/.*: //")
  # ADDED / REMOVED as line-instance counts, pristine -> patched
  sort "$b.pris" | uniq -c > "$b.mp"; sort "$b.pat" | uniq -c > "$b.mf"
  join -j 2 -t$'\t' -a1 -a2 -o 0,1.1,2.1 -e 0 \
     <(awk '{c=$1; sub(/^ *[0-9]+ /,""); print c"\t"$0}' "$b.mp" | sort -t$'\t' -k2) \
     <(awk '{c=$1; sub(/^ *[0-9]+ /,""); print c"\t"$0}' "$b.mf" | sort -t$'\t' -k2) \
     > "$b.join" 2>/dev/null
  add=$(awk -F'\t' '$3>$2{s+=$3-$2} END{print s+0}' "$b.join")
  rem=$(awk -F'\t' '$2>$3{s+=$2-$3} END{print s+0}' "$b.join")
  un=$(awk -F'\t' -v re="$FOLDRE" '$2!=$3 && $1 !~ re' "$b.join" | wc -l)
  verdict=IMPROVED; [ "$df" -ge "$dp" ] 2>/dev/null && verdict=NOT-IMPROVED
  printf '%-14s %-10s | %10s -> %-10s %-5s | %8s %8s | %s\n' \
         "$T" "$M" "$dp" "$df" "$verdict" "$add" "$rem" "$un"
  n=$((n+1))
done
echo "movers examined: $n   SKIPPED: $miss"
[ "$n" -gt 0 ] || { echo "REFUSING TO REPORT: examined nothing"; exit 5; }
