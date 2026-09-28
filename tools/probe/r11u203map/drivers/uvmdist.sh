#!/bin/bash
# uvmdist.sh <sweep workdir>...: for the UVM rows (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard; both modes), the
# ORDER-BLIND distance of each sweep's database to its golden: uhdm-strictcmp's per-object records (--dump-a/-b:
# depth type name defname fullname file line col endline endcol decompile size value consttype) as multisets, the
# depth column dropped; prints ours-not-in-golden records (dist), and the same restricted to the file facet of
# method_func_call records (mfc_file_away: (name,file) pairs ours holds more often than golden).
# r11u179: the fence from common.fenced(), scratch under /tmp/r11u203_uvmdist. r11u175: also rev = golden-not-in-ours records and total = dist + rev.
# Fail-closed on $FENCED (these four rows are not fenced; the check is kept for reuse).
FENCED="$(python3 -c "import sys; sys.path.insert(0,'$(dirname "$0")'); import common; print(' '.join(sorted(common.fenced())))")"; [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "uvmdist.sh: fence unreadable" >&2; exit 2; }
T=${UVMDIST_TMP:-/tmp/r11u203_uvmdist}; mkdir -p $T
for W in "$@"; do
  for t in ${UVMDIST_TESTS:-MiniAmiq SeqDriver SimpleUVM Scoreboard BuildUVMPkg ApbSlave SVSwitch}; do
    for f in $FENCED; do [ "$f" = "$t" ] && continue 2; done
    for m in default testflags; do
      d=$(ls -d $W/surelog/$m/$t-* 2>/dev/null | head -1); [ -s "$d/slang.uhdm" ] || continue
      g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}'); gu=$(find $g -name '*.uhdm' | head -1)
      ${STRICT_CMP:-/tmp/r11u203_bin/uhdm-strictcmp} --max 0 --dump-a $T/a --dump-b $T/b $gu $d/slang.uhdm > /dev/null 2>&1
      python3 - "$T/a" "$T/b" "$W" "$t" "$m" <<'PY'
import sys, collections
a = collections.Counter(l.split('\t', 1)[1] for l in open(sys.argv[1]) if '\t' in l)
b = collections.Counter(l.split('\t', 1)[1] for l in open(sys.argv[2]) if '\t' in l)
dist = sum((b - a).values())
def mf(c):
    r = collections.Counter()
    for k, v in c.items():
        f = k.split('\t')
        if f[0] == 'method_func_call': r[(f[1], f[4])] += v
    return r
away = sum((mf(b) - mf(a)).values())
rev = sum((a - b).values())
print('%s %s/%s dist=%d rev=%d total=%d mfc_file_away=%d golden_records=%d ours_records=%d' % (sys.argv[3], sys.argv[4], sys.argv[5], dist, rev, dist + rev, away, sum(a.values()), sum(b.values())))
PY
    done
  done
done
