#!/usr/bin/env bash
# r10v129 verifier boundary: run BOTH frozen binaries in BOTH views over a list
# of arm files, normalise the workdir path out of the dumps, and report which
# arms MOVED and by how many lines.  Children read </dev/null; PROCESSED is
# asserted against LISTED; scratch is keyed on the RELATIVE path.
set -u
PRIS=/tmp/v129_pris.bin; PAT=/tmp/v129_pat.bin
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
ROOT=$1; OUT=$2; mkdir -p "$OUT"
LISTED=0; PROCESSED=0; MOVED=0; NOPAIR=0
: > "$OUT/moved.txt"; : > "$OUT/movedlines.txt"
while IFS= read -r f <&3; do
  LISTED=$((LISTED+1))
  rel=${f#$ROOT/}; key=$(printf '%s' "$rel" | tr '/' '_')
  d="$OUT/$key"; mkdir -p "$d"; cp "$f" "$d/src.sv"
  lang=-sv; case "$f" in *.v) lang=;; esac
  for v in def elab; do
    fl=""; [ $v = elab ] && fl=--elabuhdm
    ( cd "$d" && "$PRIS" src.sv $fl -o p_$v.uhdm >p_$v.log 2>&1 </dev/null ); echo "rc_pris_$v=$?" >> "$d/rc.txt"
    ( cd "$d" && "$PAT"  src.sv $fl -o q_$v.uhdm >q_$v.log 2>&1 </dev/null ); echo "rc_pat_$v=$?"  >> "$d/rc.txt"
    if [ -f "$d/p_$v.uhdm" ] && [ -f "$d/q_$v.uhdm" ]; then
      "$DUMP" "$d/p_$v.uhdm" 2>/dev/null | sed "s#$d/##g" > "$d/p_$v.txt"
      "$DUMP" "$d/q_$v.uhdm" 2>/dev/null | sed "s#$d/##g" > "$d/q_$v.txt"
      n=$(diff "$d/p_$v.txt" "$d/q_$v.txt" | grep -c '^[<>]'; true)
      if [ "$n" -gt 0 ]; then MOVED=$((MOVED+1)); echo "MOVED $rel/$v $n lines" >> "$OUT/moved.txt"
        diff "$d/p_$v.txt" "$d/q_$v.txt" | grep '^[<>]' >> "$OUT/movedlines.txt"; fi
    else
      NOPAIR=$((NOPAIR+1))
    fi
  done
  PROCESSED=$((PROCESSED+1))
done 3< <(find "$ROOT" \( -name '*.sv' -o -name '*.v' \) | sort)
echo "LISTED=$LISTED PROCESSED=$PROCESSED MOVED=$MOVED NO_OUTPUT_PAIRS=$NOPAIR"
[ "$LISTED" = "$PROCESSED" ] && echo PROCESSED-ASSERT-OK || echo PROCESSED-ASSERT-FAIL
