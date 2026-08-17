#!/bin/bash
# r10ladder1/inputs.sh — pin the EXACT pair of databases every ladder was taken
# from.
#
# A ladder is only meaningful against the two files it was measured on, and both
# sides move: `slang.uhdm` changes with every emitter pass and the golden cache
# is keyed by a hash nobody reads.  This records sha256 of BOTH sides of every
# row, plus the resolved golden path, so a later pass can prove it is looking at
# the same measurement rather than assuming it.
#
#   usage: inputs.sh <workdir> <mode:name> [<mode:name> ...] > INPUTS.txt
#
# GUARD (measure the measurer): a row whose golden or ours cannot be resolved
# prints MISSING and is COUNTED, and the script exits non-zero — a manifest that
# pinned nothing would read exactly like a manifest that pinned everything.
set -u
WD=${1:?workdir}; shift
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
bad=0; n=0
printf '# workdir %s\n' "$WD"
for spec in "$@"; do
  mode=${spec%%:*}; name=${spec#*:}
  seen=0
  for d in "$WD/$mode/$name"-*/; do
    [ -d "$d" ] || continue
    seen=1
    O=$d/slang.uhdm
    G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" 2>/dev/null | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
      printf '%-9s %-14s MISSING golden=%s ours=%s\n' "$mode" "$name" "${G:-none}" "$O"
      bad=$((bad+1)); continue
    fi
    printf '%-9s %-14s golden %s  %s\n' "$mode" "$name" "$(sha256sum "$G" | cut -d' ' -f1)" "$G"
    printf '%-9s %-14s ours   %s  %s\n' "$mode" "$name" "$(sha256sum "$O" | cut -d' ' -f1)" "$O"
    n=$((n+1))
  done
  [ "$seen" -eq 0 ] && { printf '%-9s %-14s UNKNOWN-NAME\n' "$mode" "$name"; bad=$((bad+1)); }
done
printf '# pinned=%d missing=%d\n' "$n" "$bad"
[ "$n" -gt 0 ] && [ "$bad" -eq 0 ]
