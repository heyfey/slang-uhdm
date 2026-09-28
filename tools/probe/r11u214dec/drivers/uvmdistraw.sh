#!/bin/bash
# uvmdistraw.sh <sweep workdir>...: uvmdist.sh's order-blind distance with the RAW full name (strictcmp_x's 15th
# column) in place of the canonical `<in>...` one, so full names moved inside typespec copies count. dist =
# records ours holds that golden lacks, rev = the reverse, total = both. Fence fail-closed; needs env.sh ($B, $S).
[ -n "$FENCED" ] && [ -n "$S" ] || { echo "uvmdistraw.sh: source drivers/env.sh" >&2; exit 2; }
T=$S/uvmdistraw; mkdir -p $T
for W in "$@"; do
  for t in ${UVMDIST_TESTS:-MiniAmiq SeqDriver SimpleUVM Scoreboard BuildUVMPkg}; do
    for f in $FENCED; do [ "$f" = "$t" ] && continue 2; done
    for m in default testflags; do
      d=$(ls -d $W/surelog/$m/$t-* 2>/dev/null | head -1); [ -s "$d/slang.uhdm" ] || continue
      g=$(grep -o 'goldens/[0-9a-f]*' $d/cmds.txt | head -1); gu=$HOME/.cache/slang-uhdm-goldens/${g#goldens/}/golden.uhdm
      $B/strictcmp_x --max 0 --dump-a $T/a --dump-b $T/b $gu $d/slang.uhdm > /dev/null 2>&1
      python3 - "$T/a" "$T/b" "$W" "$t" "$m" <<'PY'
import sys, collections
def recs(p):
    c = collections.Counter()
    for l in open(p, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if len(f) < 15: continue
        f[4] = f[14].split('\x1f')[0]
        c['\t'.join(f[1:14])] += 1
    return c
a, b = recs(sys.argv[1]), recs(sys.argv[2])
dist = sum((b - a).values()); rev = sum((a - b).values())
print('%s %s/%s rawdist=%d rawrev=%d rawtotal=%d' % (sys.argv[3], sys.argv[4], sys.argv[5], dist, rev, dist + rev))
PY
    done
  done
done
