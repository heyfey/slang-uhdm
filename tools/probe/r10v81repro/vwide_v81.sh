#!/usr/bin/env bash
# r10v81 WIDE BOUNDARY — EVERY .sv AND .v under a COPY of tools/probe, at ANY
# depth, no path filter, both views, both frozen binaries, workdir-normalised
# whole-dump byte compare.  The file list is read on fd 3; every child runs
# </dev/null; rc is recorded per cell; PROCESSED is asserted against LISTED.
# The four slang-fenced names are SKIPPED and only listed.  MEASUREMENT ONLY.
set -u
PAT=/tmp/v81_bin/patched; PRIS=/tmp/v81_bin/pris
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
ROOT=${PROBE_ROOT:?}; STAGE=${STAGE:?}; LIST=$1; OUT=$2; JOBS=${JOBS:-6}
mkdir -p "$STAGE"
: > $OUT.cells; : > $OUT.signal; : > $OUT.fenced
cell() {
  local f=$1 rel key b d rc
  rel=${f#$ROOT/}
  case "$rel" in *UnsignedParam*|*HierPathEval*|*FileLocalParam*|*TopParam*)
      echo "FENCED $rel" >> $OUT.fenced; echo "FENCED $rel" >> $OUT.cells; return;; esac
  key=$(echo "$rel" | tr '/.' '__')
  b=$(basename "$f")
  for view in plain elab; do
    local FLAGS=""; [ $view = elab ] && FLAGS="--elabuhdm"
    local ok=1
    for side in A B; do
      local BIN=$PAT; [ $side = B ] && BIN=$PRIS
      d="$STAGE/${key}_${view}_$side"; mkdir -p "$d"; cp "$f" "$d/" 2>/dev/null || { ok=0; continue; }
      ( cd "$d" && "$BIN" $FLAGS "$b" -o slang.uhdm >slang.log 2>&1 </dev/null ); rc=$?
      echo "RC $rc $side $view $rel" >> $OUT.cells
      [ "$rc" -gt 128 ] && echo "SIGNAL rc=$rc $side $view $rel" >> $OUT.signal
      [ -f "$d/slang.uhdm" ] || { ok=0; continue; }
      "$DUMP" "$d/slang.uhdm" 2>/dev/null | sed '1d' | sed "s#${key}_${view}_$side#WD#g; s#$STAGE#STG#g" > "$d/o.norm"
      [ -s "$d/o.norm" ] || ok=0
    done
    if [ "$ok" = 0 ]; then echo "NOOUT $view $rel" >> $OUT.cells
    elif cmp -s "$STAGE/${key}_${view}_A/o.norm" "$STAGE/${key}_${view}_B/o.norm"; then
      echo "SAME $view $rel" >> $OUT.cells
    else echo "DIFF $view $rel" >> $OUT.cells; fi
    rm -rf "$STAGE/${key}_${view}_A" "$STAGE/${key}_${view}_B"
  done
  echo "DONE $rel" >> $OUT.cells
}
n=0
while read -r f <&3; do
  n=$((n+1))
  while [ "$(jobs -rp | wc -l)" -ge "$JOBS" ]; do wait -n; done
  cell "$f" </dev/null &
done 3< "$LIST"
wait
listed=$(wc -l < "$LIST")
processed=$(grep -c '^DONE ' $OUT.cells; true); fenced=$(grep -c '^FENCED ' $OUT.cells; true)
same=$(grep -c '^SAME ' $OUT.cells; true); diffn=$(grep -c '^DIFF ' $OUT.cells; true)
noout=$(grep -c '^NOOUT ' $OUT.cells; true); sig=$(wc -l < $OUT.signal)
echo "LISTED=$listed PROCESSED=$((processed+fenced)) FENCED=$fenced identical=$same DIFFERING=$diffn no_output=$noout SIGNAL_CELLS=$sig" > $OUT.tally
grep '^DIFF ' $OUT.cells | sort > $OUT.diff
cat $OUT.tally
