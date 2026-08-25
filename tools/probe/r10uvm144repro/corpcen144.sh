#!/usr/bin/env bash
# r10uvm144 -- the CALL-ARGUMENT BINDING census over the NAMED corpus rows of a
# verify_golden workdir, golden vs ours, joined as a MULTISET (a set join hides
# a collapse; a last-writer dict drops rows).
#   usage: DUMP=.. SCAN=.. corpcen144.sh <workdir> <name> [<name> ...]
# Prints, per row:  <name>/<mode>  ROWS g=<n> o=<n>  ONLY-GOLDEN=<n> ONLY-OURS=<n>
set -u
WD=$(readlink -f "${1:?workdir}"); shift
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
SCAN=${SCAN:-$(dirname "$(readlink -f "$0")")/argscan144.py}
T=$(mktemp -d "${TMPDIR:-/tmp}/cen144.XXXXXX")
trap 'rm -rf "$T"' EXIT
for nm in "$@"; do
  for mode in default testflags; do
    d=$(ls -d "$WD/$mode/$nm"-* 2>/dev/null | head -1)
    [ -n "$d" ] && [ -f "$d/slang.uhdm" ] || { echo "$nm/$mode  SKIP-NOOURS"; continue; }
    g=$(sed -n 's/.*golden cache hit \(.*\))/\1/p' "$d/cmds.txt")/golden.uhdm
    [ -f "$g" ] || { echo "$nm/$mode  SKIP-NOGOLDEN"; continue; }
    "$DUMP" "$g" > "$T/g.dump" 2>/dev/null
    "$DUMP" "$d/slang.uhdm" > "$T/o.dump" 2>/dev/null
    python3 "$SCAN" "$T/g.dump" full | grep '^ROW' | sort > "$T/g.rows"
    python3 "$SCAN" "$T/o.dump" full | grep '^ROW' | sort > "$T/o.rows"
    og=$(comm -23 "$T/g.rows" "$T/o.rows" | wc -l)
    oo=$(comm -13 "$T/g.rows" "$T/o.rows" | wc -l)
    printf "%s/%s  ROWS g=%s o=%s  ONLY-GOLDEN=%s ONLY-OURS=%s\n" \
      "$nm" "$mode" "$(wc -l < "$T/g.rows")" "$(wc -l < "$T/o.rows")" "$og" "$oo"
    if [ "$og" != 0 ] || [ "$oo" != 0 ]; then
      comm -23 "$T/g.rows" "$T/o.rows" | sed "s/^/  ONLY-GOLDEN $nm\/$mode /"
      comm -13 "$T/g.rows" "$T/o.rows" | sed "s/^/  ONLY-OURS   $nm\/$mode /"
    fi
  done
done
