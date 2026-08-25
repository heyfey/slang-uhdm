#!/usr/bin/env bash
# r10uvm141 -- score ONE arm dir with cen141 rows, golden vs pristine vs patched,
# in BOTH views.  The join is a MULTISET join (a class with several
# qualifier+lifetime methods collapses to ONE object in golden but not in ours,
# and a set-level join would hide that by deduplicating identical rows).
#   usage: [PAT=regex] score141.sh <armdir>
# MEASUREMENT ONLY -- the judge is uhdm-cmp.
set -u
D=${1:?armdir}; PAT=${PAT:-.}
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
for t in g o q ge oe qe; do
  [ -f "$D/$t.uhdm" ] || continue
  "$DUMP" "$D/$t.uhdm" 2>/dev/null > "$D/$t.dump"
  python3 "$HERE/cen141.py" "$D/$t.dump" | grep -E "$PAT" | sort > "$D/$t.cen"
done
for pair in "g o DEF-pristine" "g q DEF-patched" "ge oe ELAB-pristine" "ge qe ELAB-patched"; do
  set -- $pair
  [ -f "$D/$1.cen" ] && [ -f "$D/$2.cen" ] || continue
  python3 - "$D/$1.cen" "$D/$2.cen" "$3" <<'PY'
import sys, collections
g = collections.Counter(open(sys.argv[1]).read().splitlines())
x = collections.Counter(open(sys.argv[2]).read().splitlines())
og = sum((g - x).values()); ox = sum((x - g).values())
print("%-14s goldencells=%-4d ourcells=%-4d ONLY-GOLDEN=%-4d ONLY-OURS=%-4d"
      % (sys.argv[3], sum(g.values()), sum(x.values()), og, ox))
for k, n in sorted((g - x).items()):
    print("    ONLY-GOLDEN x%d %s" % (n, k))
for k, n in sorted((x - g).items()):
    print("    ONLY-OURS   x%d %s" % (n, k))
PY
done
