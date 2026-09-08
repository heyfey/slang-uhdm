#!/usr/bin/env bash
# r10uvm206 — cenrows206.sh — MEASUREMENT ONLY.  The official uhdm-cmp is the
# sole judge.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# The DESIGN typespec-listing census over a NAMED SUBSET of two verify_golden
# workdirs (pristine and patched), both modes.  The golden path is read out of
# each workdir's OWN cmds.txt so the census cannot compare against the wrong
# golden, and a missing side prints SKIP-NOFILE and is COUNTED.
#
#   usage: TS=<ct206ts> JOIN=<cen206.py> ./cenrows206.sh <wd_pris> <wd_pat> <out> <name>...
set -u
TS=${TS:?}; JOIN=${JOIN:?}
A=${1:?wd_pris}; B=${2:?wd_pat}; OUT=${3:?out}; shift 3
: > "$OUT"
miss=0; done_=0
gold () { # $1 = test dir
  local c="$1/cmds.txt" g=""
  [ -f "$c" ] && g=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$c" | head -1)
  [ -n "$g" ] && [ -d "$g" ] && echo "$g/golden.uhdm"
}
for n in "$@"; do
  for mode in default testflags; do
    for da in "$A/$mode/$n"-*/; do
      [ -d "$da" ] || continue
      db=$(echo "$B/$mode/$n"-*/ | awk '{print $1}')
      G=$(gold "$da")
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$da/slang.uhdm" ] || [ ! -f "$db/slang.uhdm" ]; then
        echo "ROW $n $mode SKIP-NOFILE" >> "$OUT"; miss=$((miss+1)); continue
      fi
      "$TS" "$G"             > "$OUT.g" 2>/dev/null
      "$TS" "$da/slang.uhdm" > "$OUT.a" 2>/dev/null
      "$TS" "$db/slang.uhdm" > "$OUT.b" 2>/dev/null
      echo "ROW $n $mode PRIS    $(python3 "$JOIN" "$OUT.g" "$OUT.a")" >> "$OUT"
      echo "ROW $n $mode PATCHED $(python3 "$JOIN" "$OUT.g" "$OUT.b")" >> "$OUT"
      python3 "$JOIN" "$OUT.g" "$OUT.b" --diffs | sed "s/^/CELL $n.$mode /" >> "$OUT"
      done_=$((done_+1))
    done
  done
done
rm -f "$OUT.g" "$OUT.a" "$OUT.b"
{
  echo "-- ROWS=$done_ SKIP-NOFILE=$miss"
  echo "-- PATCHED  MOVED-WRONG(=TS-DIFF) $(awk '/PATCHED/{split($0,a,"TS-DIFF=");split(a[2],b," ");s+=b[1]}END{print s+0}' "$OUT")  AWAY-GOLDEN(=SET-ONLY-OURS) $(awk '/PATCHED/{split($0,a,"SET-ONLY-O=");split(a[2],b," ");s+=b[1]}END{print s+0}' "$OUT")"
  echo "-- PRIS     TS-DIFF $(awk '/ PRIS /{split($0,a,"TS-DIFF=");split(a[2],b," ");s+=b[1]}END{print s+0}' "$OUT")  SET-ONLY-OURS $(awk '/ PRIS /{split($0,a,"SET-ONLY-O=");split(a[2],b," ");s+=b[1]}END{print s+0}' "$OUT")"
} >> "$OUT"
tail -3 "$OUT"
