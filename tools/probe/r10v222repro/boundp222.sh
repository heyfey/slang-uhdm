#!/usr/bin/env bash
# r10v222 — the WIDE BOUNDARY GATE, PARALLEL.  Same contract as
# r10uvm222repro/bound222.sh (from which every guard is taken): both binaries
# over EVERY .sv arm in a COPY of the whole probe tree, SUBDIRECTORIES
# included, BOTH views, every rc recorded and compared, scratch keyed on the
# RELATIVE path, children </dev/null, PROCESSED asserted == LISTED.  The only
# change is that arms are dispatched by `xargs -P` instead of one at a time;
# an arm's two runs stay inside one child, so a run never races its own pair.
# MEASUREMENT ONLY.
#   usage: boundp222.sh <probe-tree> <scratch> <out> <binA> <binB> [jobs]
set -u
TREE=${1:?probe tree}; SCR=${2:?scratch}; OUT=${3:?out}
A=${4:?binary A}; B=${5:?binary B}; J=${6:-5}
[ -x "$A" ] || { echo "FATAL: no binary $A"; exit 3; }
[ -x "$B" ] || { echo "FATAL: no binary $B"; exit 3; }
[ -d "$TREE" ] || { echo "FATAL: no tree $TREE"; exit 3; }
rm -rf "$SCR"; mkdir -p "$SCR/tree" "$SCR/rec" || exit 1
cp -r "$TREE"/. "$SCR/tree"/ || exit 1
LIST=$SCR/list.txt
( cd "$SCR/tree" && find . -name '*.sv' -type f | sort ) > "$LIST"
listed=$(wc -l < "$LIST")
one_arm() {
  rel=$1
  key=$(echo "$rel" | sed 's|^\./||; s|/|__|g; s|\.sv$||')
  rec=$SCR/rec/$key.txt
  : > "$rec"
  for ev in def elab; do
    d=$SCR/run/$key.$ev
    mkdir -p "$d" || exit 1
    ex=""; [ "$ev" = elab ] && ex="--elabuhdm"
    ( cd "$SCR/tree/$(dirname "$rel")" && timeout 120 "$A" $ex "$(basename "$rel")" -o "$d/a.uhdm" > "$d/a.log" 2>&1 </dev/null ); arc=$?
    ( cd "$SCR/tree/$(dirname "$rel")" && timeout 120 "$B" $ex "$(basename "$rel")" -o "$d/b.uhdm" > "$d/b.log" 2>&1 </dev/null ); brc=$?
    if [ "$arc" != "$brc" ]; then
      echo "RCDIFF $rel $ev rcA=$arc rcB=$brc" >> "$rec"; continue
    fi
    if [ -f "$d/a.uhdm" ] && [ -f "$d/b.uhdm" ]; then
      ma=$(md5sum "$d/a.uhdm" | cut -c1-12); mb=$(md5sum "$d/b.uhdm" | cut -c1-12)
      if [ "$ma" != "$mb" ]; then
        echo "MOVED $rel $ev a=$ma b=$mb rc=$arc" >> "$rec"
      else
        rm -f "$d/a.uhdm" "$d/b.uhdm"
      fi
    elif [ -f "$d/a.uhdm" ] || [ -f "$d/b.uhdm" ]; then
      echo "ONESIDE $rel $ev a=$([ -f "$d/a.uhdm" ] && echo yes || echo NO) b=$([ -f "$d/b.uhdm" ] && echo yes || echo NO)" >> "$rec"
    fi
  done
  echo "DONE $rel" >> "$rec"
}
export -f one_arm; export SCR A B
xargs -P "$J" -I{} bash -c 'one_arm "$@"' _ {} < "$LIST"
cat "$SCR"/rec/*.txt > "$SCR/all.txt"
grep -v '^DONE ' "$SCR/all.txt" | sort > "$OUT"; true
proc=$(grep -c '^DONE ' "$SCR/all.txt"; true)
moved=$(grep -c '^MOVED\|^ONESIDE' "$OUT"; true)
rcdiff=$(grep -c '^RCDIFF' "$OUT"; true)
echo "-- LISTED=$listed PROCESSED=$proc MOVED_ARMS=$moved RC_DIFFS=$rcdiff" >> "$OUT"
tail -1 "$OUT"
[ "$listed" -eq "$proc" ] || { echo "FATAL: LISTED != PROCESSED"; exit 4; }
