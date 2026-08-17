#!/usr/bin/env bash
# r10rgg4/rggencensus.sh — the GOLDEN-vs-GOLDEN census of the Rggen head family,
# taken BEFORE the code was written and re-taken after, on the real databases.
#
#   usage: rggencensus.sh <golden.uhdm> <base_slang.uhdm> <pat_slang.uhdm>
#
# Prints every ELABORATED interface_array dimension bound of the design, so the
# DEFICIT (golden rows ours does not reproduce) can be counted by name.
# GUARD: a side that yields NO interface_array line prints NONE and is counted.
set -u
G=${1:?golden}; B=${2:?base}; P=${3:?pat}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
here=$(cd "$(dirname "$0")" && pwd)
bad=0
for tag in GOLD BASE PAT; do
  case $tag in GOLD) f=$G;; BASE) f=$B;; PAT) f=$P;; esac
  d=/tmp/vrgg4_census_$tag.dump
  [ -f "$d" ] || "$DUMP" "$f" > "$d" 2>&1
  o=/tmp/vrgg4_census_$tag.rng
  python3 "$here/attrib.py" "$d" 2>/dev/null | grep 'interface_array' | grep 'ROP0' > "$o"
  n=$(wc -l < "$o")
  [ "$n" -eq 0 ] && { echo "$tag NONE"; bad=$((bad+1)); }
  echo "---- $tag ($n elab interface_array size bounds)"
  sed 's/^/  /' "$o"
done
echo "PROBLEMS=$bad"
