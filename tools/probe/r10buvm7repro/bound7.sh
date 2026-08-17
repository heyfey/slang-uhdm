#!/usr/bin/env bash
# r10buvm7 BOUNDARY CHECK — the standing rules protect the neighbouring passes'
# arms ("uvm77-82 arms, buvm3-6 arms, sd8-12 grids, uvm79's v79v1-v6 — only
# cells your law names may move").  Several of those arm files DO contain inc/dec
# statements, so "my law touches nothing there" cannot be asserted; it is
# MEASURED, ours-vs-ours (Surelog is never run: the question is pristine-vs-
# patched, not either-vs-golden).
#
#   usage: bound7.sh <patched-binary> <pristine-binary> <outdir> <armfile> [...]
#
# Per arm:
#   DIFFLINES  raw `-`/`+` line count between the two dumps.
#   FLIPS      inc/dec operand positions that went PATH -> WIDEREF (the census's
#              verdict: exactly the law's firing set).
#   RESIDUE    DIFFLINES after striplines7.py removed every line mentioning a
#              FLIPPED statement's source line, from BOTH sides.  RESIDUE > 0 is
#              a change this pass's law does not account for and is printed.
#
# GUARDS:
#   * uhdm-dump's FIRST LINE IS THE DATABASE PATH and always differs -> `sed 1d`.
#   * a binary that produces NO database is reported NO_DB and COUNTED; a driver
#     that reaches nothing must never read as "no movers".
#   * each arm runs in its OWN scratch dir (builtin.sv synthesis and relative
#     includes both key off the cwd).
set -u
P=${1:?patched binary}
R=${2:?pristine binary}
OUT=${3:?outdir}
shift 3
for b in "$P" "$R"; do [ -x "$b" ] || { echo "FATAL: no binary $b"; exit 3; }; done
HERE=$(cd "$(dirname "$0")" && pwd)
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CEN=${R10BUVM7CEN:-/tmp/r10buvm7cen}
STRIP=$HERE/striplines7.py
mkdir -p "$OUT" || exit 9
tot=0; nodb=0; moved=0; resid=0
printf "%-42s %10s %6s %8s %s\n" ARM DIFFLINES FLIPS RESIDUE NOTE
for f in "$@"; do
  b=$(basename "$f"); b=${b%.*}
  d=$OUT/$b; rm -rf "$d"; mkdir -p "$d" || exit 9
  cp "$f" "$d/" || exit 9
  leaf=$(basename "$f")
  ( cd "$d" && "$P" "$leaf" -o pat.uhdm >pat.log 2>&1; \
               "$R" "$leaf" -o pris.uhdm >pris.log 2>&1 )
  tot=$((tot+1))
  if [ ! -f "$d/pat.uhdm" ] || [ ! -f "$d/pris.uhdm" ]; then
    printf "%-42s %10s %6s %8s %s\n" "$b" - - - \
      "NO_DB(pat=$( [ -f "$d/pat.uhdm" ] && echo y || echo n) pris=$( [ -f "$d/pris.uhdm" ] && echo y || echo n))"
    nodb=$((nodb+1)); continue
  fi
  "$DUMP" "$d/pat.uhdm"  2>/dev/null | sed 1d > "$d/pat.dump"
  "$DUMP" "$d/pris.uhdm" 2>/dev/null | sed 1d > "$d/pris.dump"
  n=$(diff "$d/pris.dump" "$d/pat.dump" | grep -cE '^[<>]' || true)
  "$CEN" "$d/pris.uhdm" PRIS > "$d/pris.cen"
  "$CEN" "$d/pat.uhdm"  PAT  > "$d/pat.cen"
  # a FLIP is a position that is PATH in pristine and WIDEREF in patched
  awk '/^INCDEC/ && $5=="PATH"{split($3,a,":"); print a[1]}' "$d/pris.cen" | sort -u > "$d/pris.path"
  awk '/^INCDEC/ && $5=="WIDEREF"{split($3,a,":"); print a[1]}' "$d/pat.cen" | sort -u > "$d/pat.wide"
  comm -12 "$d/pris.path" "$d/pat.wide" > "$d/flip.lines"
  fl=$(wc -l < "$d/flip.lines")
  if [ "$fl" -gt 0 ]; then
    python3 "$STRIP" "$d/pris.dump" $(cat "$d/flip.lines") > "$d/pris.strip" 2>/dev/null
    python3 "$STRIP" "$d/pat.dump"  $(cat "$d/flip.lines") > "$d/pat.strip"  2>/dev/null
  else
    cp "$d/pris.dump" "$d/pris.strip"; cp "$d/pat.dump" "$d/pat.strip"
  fi
  r=$(diff <(sort "$d/pris.strip") <(sort "$d/pat.strip") | grep -cE '^[<>]' || true)
  note=OK
  [ "$n" -gt 0 ] && { moved=$((moved+1)); note=MOVED; }
  if [ "$r" -gt 0 ]; then note=RESIDUE; resid=$((resid+1)); fi
  printf "%-42s %10s %6s %8s %s\n" "$b" "$n" "$fl" "$r" "$note"
  if [ "$r" -gt 0 ]; then
    echo "     ---- RESIDUE lines (< = pristine, > = patched):"
    diff <(sort "$d/pris.strip") <(sort "$d/pat.strip") | grep -E '^[<>]' | head -20 | sed 's/^/     /'
  fi
done
echo "-- arms=$tot MOVED=$moved RESIDUE-ARMS=$resid NO_DB=$nodb"
[ "$resid" -eq 0 ] && echo "PASS: outside the FLIPPED statements the two dumps are IDENTICAL multisets" \
                   || { echo "FAIL: a change outside the flipped statements"; exit 1; }
