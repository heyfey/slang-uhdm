#!/usr/bin/env bash
# r10earl38 — THE OBJECT-LEVEL MOVER FENCE, computed from the DUMPS.
#
#   usage: cenpred38.sh <golden.dump> <ours.dump> [outdir]
#
# Both dumps must already have uhdm-dump's FIRST LINE (the database path)
# stripped, and — when they come from different workdirs — have the `file:`
# paths normalised, or every `file:` line reads as a difference (the documented
# cross-workdir trap).
#
# Prints the DEF-view generate-branch census rows that DISAGREE, split into the
# two groups that matter:
#
#   MISSING  golden's block has statements ours does not  -> the predicted
#            movers of § genChainBranchScopeThreads38
#   OTHER    the row differs some other way (a span, an extra statement)  ->
#            NOT this law; these must be BYTE-IDENTICAL after the patch
#
# Why an object-level fence and not a source-text one: `pred38.py` cannot tell
# a chain branch nested in a GENERATE SCOPE (broken) from one at MODULE LEVEL
# (already correct), and the two are written identically.  This instrument
# reads the actual objects, so its count is exact.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
G=${1:?golden dump}
O=${2:?ours dump}
D=${3:-/tmp/r10earl38_cenpred}
for f in "$G" "$O"; do
  [ -s "$f" ] || { echo "NO_INPUT: missing or empty $f"; exit 6; }
done
mkdir -p "$D" || exit 9
python3 "$HERE/blkcen38.py" -v all "$G" > "$D/g.cen" || exit 7
python3 "$HERE/blkcen38.py" -v all "$O" > "$D/o.cen" || exit 7
echo "census rows: golden=$(wc -l < "$D/g.cen") ours=$(wc -l < "$D/o.cen")"
diff -u "$D/g.cen" "$D/o.cen" > "$D/cen.diff"
echo "differing census rows (golden side): $(grep -cE '^-def' "$D/cen.diff")"
python3 - "$D/cen.diff" <<'EOF'
import re, sys
gs, os_ = [], []
for ln in open(sys.argv[1], errors='replace'):
    if ln.startswith('-def'):
        gs.append(ln[1:].rstrip('\n'))
    elif ln.startswith('+def'):
        os_.append(ln[1:].rstrip('\n'))


def key(ln):
    return ln.split()[1]


def n(ln):
    m = re.search(r'n=(\d+)', ln)
    return int(m.group(1)) if m else -1


gm, om = {}, {}
for ln in gs:
    gm.setdefault(key(ln), []).append(ln)
for ln in os_:
    om.setdefault(key(ln), []).append(ln)
miss = 0
missblocks = 0
print('--- MISSING (golden has statements we do not) — the predicted movers')
for k in sorted(set(gm) | set(om)):
    gl, ol = gm.get(k, []), om.get(k, [])
    gt, ot = sum(n(x) for x in gl), sum(n(x) for x in ol)
    if gt > ot:
        miss += gt - ot
        missblocks += 1
        print('  %-52s golden=%d ours=%d  MISSING %d' % (k, gt, ot, gt - ot))
print('--- OTHER (same statement count, some other difference) — NOT this law')
for k in sorted(set(gm) | set(om)):
    gl, ol = gm.get(k, []), om.get(k, [])
    gt, ot = sum(n(x) for x in gl), sum(n(x) for x in ol)
    if gt <= ot:
        print('  %-52s golden=%d ours=%d' % (k, gt, ot))
print()
print('PREDICTION: %d statement objects missing across %d block names' %
      (miss, missblocks))
EOF
echo "WD=$D"
