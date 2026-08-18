#!/usr/bin/env bash
# r10buvm16repro/cenall16.sh — run the `new` census over EVERY
# database in a verify_golden workdir, on BOTH sides, into one file per side.
#
#   usage: cenall16.sh <workdir> <out-prefix>
#
# GUARDS:
#   * the GOLDEN path is read out of each dir's OWN cmds.txt (never guessed),
#     and the cache DIRECTORY is turned into .../golden.uhdm.
#   * a dir whose golden or ours is missing is COUNTED and named, never skipped
#     silently — a census that reached nothing must not read as agreement.
#   * the TEST NAME and MODE are prefixed onto every row so the join can never
#     mix two tests that share a file:line key (uvm_pkg.sv is shared by many).
set -u
WD=${1:?workdir}
P=${2:?out prefix}
CEN=${CEN:-/tmp/r10buvm16cen}
[ -x "$CEN" ] || { echo "FATAL: no census binary $CEN"; exit 3; }
: > "$P.golden"; : > "$P.ours"
n=0; miss=0
for d in "$WD"/*/*/; do
  [ -f "$d/cmds.txt" ] || continue
  mode=$(basename "$(dirname "$d")"); test=$(basename "$d")
  O=$d/slang.uhdm
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
    echo "MISSING $mode/$test g=${G:-none}"; miss=$((miss+1)); continue
  fi
  "$CEN" "$G" "$mode/$test" >> "$P.golden"
  "$CEN" "$O" "$mode/$test" >> "$P.ours"
  n=$((n+1))
done
echo "CENSUS dirs=$n MISSING=$miss -> $P.golden $P.ours"
