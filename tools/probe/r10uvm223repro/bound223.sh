#!/usr/bin/env bash
# r10uvm223 — THE WIDE BOUNDARY GATE (copied unchanged from r10uvm221repro/bound223.sh
# except that a MOVED arm KEEPS its two databases, so the mover can be
# attributed line by line without re-running the pair).  MEASUREMENT ONLY.
#
# Runs BOTH binaries over EVERY `.sv` arm in a COPY of the whole probe tree —
# SUBDIRECTORIES INCLUDED (sd8-12 keep arms in subdirs; a top-level glob ran
# nothing and printed green) — in BOTH views, and reports every arm whose
# database MOVED.  The wide boundary is the only gate that convicts a
# corpus-invisible regression (earl60's two).
#
# The traps this driver is written against, each one paid for by an earlier
# pass:
#   * the file list is read on FD 3 and every child gets `</dev/null`, because a
#     stdin-list was swallowed whole by the first child;
#   * PROCESSED is asserted equal to LISTED, so a driver that reaches nothing
#     can never read as perfection;
#   * scratch is keyed on the arm's RELATIVE PATH, because `r10uvm33repro` has
#     three files called `dut.sv`;
#   * every rc is recorded and compared (a 139 SEGFAULT is a real difference);
#   * the tree is COPIED first, so nothing here can write into the repo.
#
#   usage: bound223.sh <probe-tree> <scratch> <out> <binA> <binB>
set -u
TREE=${1:?probe tree}; SCR=${2:?scratch}; OUT=${3:?out}
A=${4:?binary A (pristine)}; B=${5:?binary B (patched)}
[ -x "$A" ] || { echo "FATAL: no binary $A"; exit 3; }
[ -x "$B" ] || { echo "FATAL: no binary $B"; exit 3; }
[ -d "$TREE" ] || { echo "FATAL: no tree $TREE"; exit 3; }
rm -rf "$SCR"; mkdir -p "$SCR/tree" || exit 1
cp -r "$TREE"/. "$SCR/tree"/ || exit 1
: > "$OUT"
LIST=$SCR/list.txt
( cd "$SCR/tree" && find . -name '*.sv' -type f | sort ) > "$LIST"
listed=$(wc -l < "$LIST")
proc=0; moved=0; rcdiff=0
while read -r rel <&3; do
  proc=$((proc+1))
  key=$(echo "$rel" | sed 's|^\./||; s|/|__|g; s|\.sv$||')
  for ev in def elab; do
    d=$SCR/run/$key.$ev
    mkdir -p "$d" || exit 1
    ex=""; [ "$ev" = elab ] && ex="--elabuhdm"
    ( cd "$SCR/tree/$(dirname "$rel")" && timeout 120 "$A" $ex "$(basename "$rel")" -o "$d/a.uhdm" > "$d/a.log" 2>&1 </dev/null ); arc=$?
    ( cd "$SCR/tree/$(dirname "$rel")" && timeout 120 "$B" $ex "$(basename "$rel")" -o "$d/b.uhdm" > "$d/b.log" 2>&1 </dev/null ); brc=$?
    if [ "$arc" != "$brc" ]; then
      echo "RCDIFF $rel $ev rcA=$arc rcB=$brc" >> "$OUT"
      rcdiff=$((rcdiff+1)); continue
    fi
    if [ -f "$d/a.uhdm" ] && [ -f "$d/b.uhdm" ]; then
      ma=$(md5sum "$d/a.uhdm" | cut -c1-12); mb=$(md5sum "$d/b.uhdm" | cut -c1-12)
      if [ "$ma" != "$mb" ]; then
        echo "MOVED $rel $ev a=$ma b=$mb rc=$arc" >> "$OUT"
        moved=$((moved+1))
      fi
    elif [ -f "$d/a.uhdm" ] || [ -f "$d/b.uhdm" ]; then
      echo "ONESIDE $rel $ev a=$([ -f "$d/a.uhdm" ] && echo yes || echo NO) b=$([ -f "$d/b.uhdm" ] && echo yes || echo NO)" >> "$OUT"
      moved=$((moved+1))
    fi
    if [ "${ma:-}" = "${mb:-}" ]; then rm -f "$d/a.uhdm" "$d/b.uhdm"; fi
    ma=""; mb=""
  done
done 3< "$LIST"
echo "-- LISTED=$listed PROCESSED=$proc MOVED_ARMS=$moved RC_DIFFS=$rcdiff" >> "$OUT"
tail -1 "$OUT"
[ "$listed" -eq "$proc" ] || { echo "FATAL: LISTED != PROCESSED"; exit 4; }
