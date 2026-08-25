#!/usr/bin/env bash
# r10uvm141 -- the CORPUS census: run cen141 over golden and ours for each NAMED
# row of a verify_golden workdir, in both modes, and print the multiset join.
# One row per class-method listing, keyed by OWNER x KIND x NAME x FIELDS x the
# names of the listed variables -- no span, no file, no id (our objects and
# golden's disagree on all three by construction).
# Dumps are deleted as soon as they are censused (each is ~40 MB of text).
#   usage: corpcen141.sh <workdir> <outdir> <name> [<name> ...]
# MEASUREMENT ONLY -- the judge is the official uhdm-cmp.
set -u
WD=${1:?workdir}; OUT=${2:?outdir}; shift 2
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
mkdir -p "$OUT"
printf "%-14s %-9s %8s %8s %12s %12s\n" TEST MODE GOLDEN OURS ONLY-GOLDEN ONLY-OURS
for n in "$@"; do
  for mode in default testflags; do
    for d in "$WD/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      C=$d/cmds.txt; O=$d/slang.uhdm; G=""
      [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
        printf "%-14s %-9s %8s %8s %12s %12s  SKIP-NOFILE\n" "$n" "$mode" - - - -
        continue
      fi
      "$DUMP" "$G" 2>/dev/null > "$OUT/$n.$mode.g.dump"
      python3 "$HERE/cen141.py" "$OUT/$n.$mode.g.dump" | sort > "$OUT/$n.$mode.g.cen"
      rm -f "$OUT/$n.$mode.g.dump"
      "$DUMP" "$O" 2>/dev/null > "$OUT/$n.$mode.o.dump"
      python3 "$HERE/cen141.py" "$OUT/$n.$mode.o.dump" | sort > "$OUT/$n.$mode.o.cen"
      rm -f "$OUT/$n.$mode.o.dump"
      python3 - "$OUT/$n.$mode.g.cen" "$OUT/$n.$mode.o.cen" "$n" "$mode" "$OUT/$n.$mode.diff" <<'PY'
import sys, collections
g = collections.Counter(open(sys.argv[1]).read().splitlines())
x = collections.Counter(open(sys.argv[2]).read().splitlines())
og, ox = g - x, x - g
with open(sys.argv[5], 'w') as f:
    for k, c in sorted(og.items()): f.write("ONLY-GOLDEN\tx%d\t%s\n" % (c, k))
    for k, c in sorted(ox.items()): f.write("ONLY-OURS\tx%d\t%s\n" % (c, k))
print("%-14s %-9s %8d %8d %12d %12d"
      % (sys.argv[3], sys.argv[4], sum(g.values()), sum(x.values()),
         sum(og.values()), sum(ox.values())))
PY
    done
  done
done
