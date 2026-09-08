#!/usr/bin/env bash
# r10uvm209 — cenrows209.sh — MEASUREMENT ONLY.  The official uhdm-cmp is the
# sole judge; this script only reports.  LHS is ALWAYS golden (Surelog); RHS is
# ALWAYS ours.
#
# THE VARIABLE-LISTING CENSUS over a NAMED SUBSET of two verify_golden workdirs
# (pristine and patched), BOTH MODES, scored against each row's OWN golden.
# `cen209.py` prints the listing face, the whole-database variable multiset, and
# — with `--pris` — the MOVE: WRONG->RIGHT, MOVED-WRONG and AWAY.
#
# GUARDS: the golden path is read out of each workdir's own `cmds.txt`, so the
# census cannot silently compare against the wrong golden; a missing side prints
# SKIP-NOFILE and is COUNTED (a driver that reaches nothing must never read as
# perfection); a name matching no directory prints UNKNOWN-NAME and is counted.
#
#   usage: CEN=<ct209cen> JOIN=<cen209.py> ./cenrows209.sh <wd_pris> <wd_pat> <out> <name>...
set -u
CEN=${CEN:?}; JOIN=${JOIN:?}
A=${1:?wd_pris}; B=${2:?wd_pat}; OUT=${3:?out}; shift 3
: > "$OUT"
miss=0; done_=0; unk=0
gold () {
  local c="$1/cmds.txt" g=""
  [ -f "$c" ] && g=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$c" | head -1)
  [ -n "$g" ] && [ -d "$g" ] && echo "$g/golden.uhdm"
}
for n in "$@"; do
  seen=0
  for mode in default testflags; do
    for da in "$A/$mode/$n"-*/; do
      [ -d "$da" ] || continue
      seen=1
      db=$(echo "$B/$mode/$n"-*/ | awk '{print $1}')
      G=$(gold "$da")
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$da/slang.uhdm" ] || \
         [ ! -f "$db/slang.uhdm" ]; then
        echo "ROW $n $mode SKIP-NOFILE" >> "$OUT"; miss=$((miss+1)); continue
      fi
      "$CEN" "$G"              > "$OUT.g" 2>/dev/null
      "$CEN" "$da/slang.uhdm"  > "$OUT.a" 2>/dev/null
      "$CEN" "$db/slang.uhdm"  > "$OUT.b" 2>/dev/null
      python3 "$JOIN" "$OUT.g" "$OUT.a" --tag "$n/$mode/PRIS" --show 0 >> "$OUT"
      python3 "$JOIN" "$OUT.g" "$OUT.b" --tag "$n/$mode/PATCHED" --show 6 \
              --pris "$OUT.a" >> "$OUT"
      done_=$((done_+1))
    done
  done
  [ "$seen" = 0 ] && { echo "ROW $n UNKNOWN-NAME" >> "$OUT"; unk=$((unk+1)); }
done
rm -f "$OUT.g" "$OUT.a" "$OUT.b"
{
  echo "-- ROWS=$done_ SKIP-NOFILE=$miss UNKNOWN-NAME=$unk"
  echo "-- PATCHED  MOVED-WRONG $(awk -F'MOVED-WRONG ' '/MOVE /{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")  AWAY $(awk -F'AWAY ' '/MOVE /{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")  WRONG->RIGHT $(awk -F'WRONG->RIGHT ' '/MOVE /{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")"
  echo "-- LISTING WRONG  pris $(awk -F'WRONG ' '/PRIS LISTING/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")  ->  patched $(awk -F'WRONG ' '/PATCHED LISTING/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")"
} >> "$OUT"
tail -3 "$OUT"
