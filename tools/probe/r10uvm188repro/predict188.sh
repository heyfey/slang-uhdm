#!/usr/bin/env bash
# r10uvm188repro/predict188.sh — NAME THE MOVER SET FROM PRISTINE DATABASES
# ALONE, before the patched sweep runs.  MEASUREMENT ONLY.
#
# § enumConstLitArithRender188 can only touch an enum constant whose written
# initialiser is arithmetic over integer literals.  In the PRISTINE database
# such a constant's vpiDecompile is the SOURCE TEXT of that expression, so it
# is exactly the set of enum_const rows whose decompile is not a bare literal
# and contains nothing but digits, based-literal ticks, the six modelled
# operator tokens, parentheses and spaces.  Every OTHER decompile shape (a
# name, a brace, a comma, a call) is outside the law and is listed separately
# as the ABSTAIN set so the two can be told apart by eye.
#
#   usage: CEN=<ct188cen> predict188.sh <pristine-workdir> <outfile>
set -u
WD=${1:?pristine workdir}
OUT=${2:?outfile}
CEN=${CEN:?path to ct188cen}
[ -x "$CEN" ] || { echo "FATAL: no ct188cen at $CEN"; exit 3; }
TMP=$(mktemp -d "${TMPDIR:-/tmp}/r10uvm188_pred.XXXXXX") || exit 3
trap 'rm -rf "$TMP"' EXIT
n=0; nodb=0
: > "$TMP/all.cen"
for mode in default testflags; do
  [ -d "$WD/$mode" ] || continue
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    t=$(basename "$d")
    if [ -f "$d/slang.uhdm" ]; then
      "$CEN" "$d/slang.uhdm" "$mode/$t" >> "$TMP/all.cen" 2>/dev/null || true
      n=$((n+1))
    else nodb=$((nodb+1)); fi
  done
done
python3 - "$TMP/all.cen" "$OUT" <<'PY'
import re, sys, collections
src, out = sys.argv[1], sys.argv[2]
# A decompile the law can render: literals (plain or based), the six modelled
# operators, parentheses, spaces — and at least one operator, since a bare
# literal is NOT this law.
lit = r"(?:[0-9]+)?'[sS]?[bBoOdDhH][0-9a-fA-FxXzZ_?]+|[0-9][0-9_]*"
tok = r"<<|>>|\+|-|\*|/"
full = re.compile(r"^\s*\(*\s*(?:%s)\s*\)*(?:\s*(?:%s)\s*\(*\s*(?:%s)\s*\)*)+\s*$" % (lit, tok, lit))
hasop = re.compile(r"<<|>>|[0-9)]\s*[-+*/]\s*[0-9(']")
hit = collections.Counter(); abstain = collections.Counter()
for line in open(src):
    p = line.rstrip('\n').split('|')
    if len(p) < 10: continue
    dec = p[6][4:]
    if not hasop.search(dec): continue
    key = p[0].split('/')[1].split('-')[0] + '  ' + p[4] + ' = ' + dec
    (hit if full.match(dec) else abstain)[key] += 1
with open(out, 'w') as f:
    f.write("PREDICTED MOVERS (enum constants the law renders)\n")
    for k, v in sorted(hit.items()): f.write("  MOVE  %s   x%d\n" % (k, v))
    f.write("ABSTAIN (an operator, but a shape outside the law)\n")
    for k, v in sorted(abstain.items()): f.write("  KEEP  %s   x%d\n" % (k, v))
    f.write("-- predicted-move rows=%d  abstain rows=%d\n" % (sum(hit.values()), sum(abstain.values())))
print("-- predicted-move rows=%d  abstain rows=%d" % (sum(hit.values()), sum(abstain.values())))
PY
echo "-- databases read=$n  missing=$nodb -> $OUT"
