#!/usr/bin/env bash
# r10uvm139 — A-PRIORI MOVER PREDICTION.  MEASUREMENT ONLY.
#
# Re-runs, for every row of a COMPLETED PRISTINE sweep workdir, the row's OWN
# slang command line (read from its `cmds.txt`, with the binary swapped for the
# PREDICTOR build) with PRED139 naming a per-row output file.  The predictor is
# the PRISTINE emitter plus ONE `fopen`/`fprintf` that is inert unless PRED139
# is set: it reports, from the OLD code path, every cell whose `vpiAutomatic`
# § tfItemLocalAutomaticIsNotWrittenStatic139 would change — so the mover set is
# named BEFORE the patched sweep exists.  Verified DB-inert: with and without
# PRED139 its database md5 equals the pristine binary's.
#
#   PREDBIN=<predictor> WD=<pristine workdir> OUT=<dir> predsweep139.sh
#
# Ops traps paid: the row list is read on fd 3, every child gets </dev/null,
# every rc is recorded, PROCESSED is asserted against LISTED, and each row's
# scratch is keyed on its RELATIVE path (two rows may share a basename).
set -u
shopt -s extglob
PREDBIN=${PREDBIN:?set PREDBIN=<predictor binary>}
WD=${WD:?set WD=<a completed pristine sweep workdir>}
OUT=${OUT:?set OUT=<output dir>}
mkdir -p "$OUT"
# verify_golden.py runs slang with cwd=<the test's source dir> and names the
# workdir `<test>-<sha1(dirpath)[:8]>`; cmds.txt does not record the cwd, so
# recover it by indexing every candidate corpus directory by that same hash.
# (A row whose cwd cannot be recovered is reported, never silently skipped.)
CWDMAP=$OUT/cwdmap.txt
python3 - "$CWDMAP" <<'PYEOF'
import hashlib, os, sys
roots = [os.path.expanduser('~/git-repos/Surelog/tests'),
         os.path.expanduser('~/git-repos/Surelog/third_party/tests'),
         os.path.expanduser('~/git-repos/uhdm2rtlil/test')]
with open(sys.argv[1], 'w') as out:
    for r in roots:
        for d, subs, files in os.walk(r):
            out.write('%s %s\n' % (hashlib.sha1(d.encode()).hexdigest()[:8], d))
PYEOF
LIST=$OUT/rows.txt
(cd "$WD" && find . -name cmds.txt | LC_ALL=C sort) > "$LIST"
listed=$(wc -l < "$LIST"); proc=0; withcells=0
exec 3< "$LIST"
while IFS= read -r rel <&3; do
  d=$(dirname "$rel"); tag=${d#./}; tag=${tag//\//__}
  o=$OUT/$tag; mkdir -p "$o"
  line=$(grep -m1 '^slang: ' "$WD/$d/cmds.txt" || true)
  if [ -z "$line" ]; then echo "$tag: NO-SLANG-LINE" >> "$OUT/skips.txt"; proc=$((proc+1)); continue; fi
  cmd=${line#slang:}
  cmd=${cmd##+([[:space:]])}          # cmds.txt pads the label — strip it
  # swap the recorded binary for the predictor and the -o target for our own
  cmd=$(printf '%s' "$cmd" | sed "s#^[^ ]\+#$PREDBIN#")
  cmd=$(printf '%s' "$cmd" | sed "s#-o [^ ]*#-o $o/pred.uhdm#")
  h=${tag##*-}
  src=$(awk -v h="$h" '$1==h{print $2; exit}' "$CWDMAP")
  if [ -z "$src" ]; then echo "$tag: NO-CWD" >> "$OUT/skips.txt"; proc=$((proc+1)); continue; fi
  ( cd "$src" && PRED139="$o/pred.txt" timeout 600 bash -c "$cmd" \
      > "$o/run.log" 2>&1 </dev/null ); echo "rc=$?" > "$o/rc"
  [ -s "$o/pred.txt" ] && withcells=$((withcells+1))
  rm -f "$o/pred.uhdm"
  proc=$((proc+1))
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc ROWS-WITH-CELLS=$withcells"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK
