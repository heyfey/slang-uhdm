#!/usr/bin/env bash
# r10uvm77 — PER-SHAPE grep-check of every MOVED shape AGAINST GOLDEN.
#
#   usage: mvgold77.sh <mv77 outdir> <pristine verify_golden workdir>
#
# `mv77.sh` says WHAT moved.  This says whether the move was TOWARD GOLDEN, and
# it is the only ATTRIBUTABLE measure in the byte gate: for every shape the
# patch REMOVED and every shape it ADDED, it counts that exact line
# (`grep -Fxc`, whitespace-stripped, so the same object printed at several
# depths counts once per print and never by indentation) in
#   golden   /  pristine  /  patched
# and prints the triple.  Convergence is `pristine != golden` and
# `patched == golden`.  Anything else is named.
#
# The golden path is read out of the workdir's own cmds.txt, so this cannot
# silently compare against the wrong golden, and the cache DIRECTORY is turned
# into .../golden.uhdm (handing uhdm-dump a directory dumps nothing).
set -u
MV=${1:?mv77 outdir}
WD=${2:?pristine verify_golden workdir}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump at $DUMP"; exit 3; }
bad=0
# `find`, NOT a glob: mv77.sh names its files after the relative path
# `./default/<test>/slang.uhdm`, so every tag begins with a DOT and a plain
# `*.mdiff` glob matches NOTHING and reads exactly like "no movers".
for md in $(find "$MV" -maxdepth 1 -name '*.mdiff' | sort); do
  [ -f "$md" ] || continue
  tag=$(basename "$md" .mdiff)
  rel=$(echo "$tag" | sed 's/^\._//; s/_slang\.uhdm$//')
  mode=${rel%%_*}; test=${rel#*_}
  C="$WD/$mode/$test/cmds.txt"
  [ -f "$C" ] || { echo "FATAL: no cmds.txt for $rel"; exit 4; }
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G="$G/golden.uhdm"
  [ -f "$G" ] || { echo "FATAL: no golden for $rel (G=${G:-none})"; exit 4; }
  gd=$(mktemp)
  "$DUMP" "$G" 2>/dev/null | sed 1d | sed 's/^ *//' | sort > "$gd"
  echo "=== $rel   golden=$G"
  printf '   %6s %6s %6s  %s\n' GOLD PRIS PATCH SHAPE
  # every DISTINCT line the multiset diff moved, in either direction
  grep -E '^[<>]' "$md" | sed -E 's/^[<>] //' | sort -u | while read -r line; do
    g=$(grep -Fxc -- "$line" "$gd" || true)
    p=$(grep -Fxc -- "$line" "$MV/$tag.pris" || true)
    q=$(grep -Fxc -- "$line" "$MV/$tag.fin" || true)
    v=CONVERGENT
    [ "$q" = "$g" ] || v="NOT-GOLDEN($v)"
    printf '   %6s %6s %6s  %s   %s\n' "$g" "$p" "$q" "$line" "$v"
  done
  rm -f "$gd"
done
exit $bad
