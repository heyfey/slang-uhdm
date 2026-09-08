#!/usr/bin/env bash
# r10uvm217 — THE CORPUS CENSUS over NAMED ROWS.  MEASUREMENT ONLY; the official
# uhdm-cmp / verify_golden.py are the judges.  LHS is ALWAYS golden (Surelog).
#
# For each named row in each mode, in BOTH sweep workdirs, the POSITION-KEYED
# materialized-listing census (ct217net + cen217.py) is run against THAT ROW'S
# OWN golden — read out of THAT ROW'S OWN `cmds.txt`, because a test's default
# and testflags goldens are DIFFERENT cache entries (RESUME §9; a hand-rolled
# `find | head -1` compared SeqDriver's default database against its testflags
# golden once and produced a meaningless field table).
#
# usage: CEN= PY= ./cenrows217.sh <pristine wd> <patched wd> <out> <name> [<name>...]
#
# GUARDS: a row missing on either side, or with no golden, prints SKIP-NOFILE
# and is COUNTED — a census that reaches nothing must never read as perfection.
set -u
CEN=${CEN:?path to ct217net}
PY=${PY:?path to cen217.py}
PW=${1:?pristine workdir}; QW=${2:?patched workdir}; OUT=${3:?out}
shift 3
: > "$OUT"
rows=0; skip=0; unk=0
for n in "$@"; do
  seen=0
  for mode in default testflags; do
    for d in "$PW/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      seen=1
      P=$d/slang.uhdm
      Q=$(echo "$d" | sed "s#^$PW#$QW#")/slang.uhdm
      C=$d/cmds.txt
      G=""
      [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$P" ] || [ ! -f "$Q" ]; then
        echo "ROW $n $mode SKIP-NOFILE(golden=${G:-none} pris=$([ -f "$P" ] && echo yes || echo NO) pat=$([ -f "$Q" ] && echo yes || echo NO))" >> "$OUT"
        skip=$((skip+1)); continue
      fi
      T=$(mktemp -d "${TMPDIR:-/tmp}/r10uvm217_cenrows.XXXXXX") || exit 1
      "$CEN" "$G" --vars > "$T/g.cen" 2>&1
      "$CEN" "$P" --vars > "$T/p.cen" 2>&1
      "$CEN" "$Q" --vars > "$T/q.cen" 2>&1
      cal=$(python3 "$PY" "$T/g.cen" "$T/g.cen" | tail -1)
      sp=$(python3 "$PY" "$T/g.cen" "$T/p.cen" | tail -1)
      sq=$(python3 "$PY" "$T/g.cen" "$T/q.cen" | tail -1)
      bytes=SAME; cmp -s "$P" "$Q" || bytes=MOVED
      echo "ROW $n $mode bytes=$bytes" >> "$OUT"
      echo "   CALIB    $cal" >> "$OUT"
      echo "   PRISTINE $sp" >> "$OUT"
      echo "   PATCHED  $sq" >> "$OUT"
      python3 "$PY" "$T/g.cen" "$T/p.cen" | grep -E '^CELL\|' | sed "s/^/   CELLP $n $mode /" >> "$OUT"
      python3 "$PY" "$T/g.cen" "$T/q.cen" | grep -E '^CELL\|' | sed "s/^/   CELLQ $n $mode /" >> "$OUT"
      rows=$((rows+1))
      rm -rf "$T"
    done
  done
  [ "$seen" -eq 0 ] && { echo "ROW $n UNKNOWN-NAME" >> "$OUT"; unk=$((unk+1)); }
done
echo "-- ROWS=$rows SKIP-NOFILE=$skip UNKNOWN-NAME=$unk" >> "$OUT"
tail -1 "$OUT"
