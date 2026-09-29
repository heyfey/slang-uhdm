#!/bin/bash
# rowdelta.sh <golden.uhdm> <A.uhdm> <B.uhdm> <label>: dumpdelta.sh's multiset reading for two databases of one corpus
# row-mode (paths normalised to basenames, ids dropped, the weaklyReferenced tail cut). Refuses a path holding a
# fenced name (FENCED from env.sh).
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
for x in "$1" "$2" "$3" "$4"; do for n in $FENCED; do echo "$x" | grep -qw "$n" && { echo "fenced path refused" >&2; exit 2; }; done; done
T=$(mktemp -d ${S}/rowdelta.XXXX)
norm() { "$UHDM_DUMP" "$1" 2>/dev/null | sed 1d | awk '/weaklyReferenced:$/{exit} {print}' | sed 's/id:[0-9]*//g; s#file:[^,]*/##; s#/[^ ,)]*/##g'; }
norm $1 > $T/g; norm $2 > $T/a; norm $3 > $T/b
python3 - $T "$4" <<'PY'
import sys, collections
T, lab = sys.argv[1], sys.argv[2]
G, A, B = (collections.Counter(open(f'{T}/{x}').read().splitlines()) for x in 'gab')
tw = aw = 0
for k in set(A) | set(B):
    if A[k] == B[k]: continue
    da = min(A[k], G[k]); db = min(B[k], G[k])
    if db > da: tw += db - da
    elif da > db: aw += da - db
print(f"{lab} unsorted_or_sorted_diff: onlyA={sum((A-B).values())} onlyB={sum((B-A).values())} toward={tw} away={aw}")
PY
rm -rf $T
