#!/usr/bin/env bash
# r10uvm79repro/mvgold79.sh — ATTRIBUTION: every shape that moved is counted in
# GOLDEN, in PRISTINE and in PATCHED, so "we moved" becomes "we moved TOWARDS
# GOLDEN" or does not.
#
#   usage: mvgold79.sh <patched_wd> <pristine_wd> <relpath> [<relpath> ...]
#
# For each moved shape S the row is `golden / pristine / patched`.  The law
# predicts, for a REMOVED shape, `0 / N / 0`, and for an ADDED shape, `N / 0 / N`
# — golden's count reached exactly.  Any other triple is a FINDING and is
# printed with a NOT-GOLDEN marker rather than buried in an aggregate.
#
# GUARDS:
#   * `grep -Fxc` — FIXED string, WHOLE line: a fullname is a substring of
#     longer fullnames, and a substring count would silently inflate.
#   * counts are taken on the id-stripped, whitespace-stripped dumps mv78.sh
#     already wrote, so all three sides are normalised identically.
#   * `grep -c` exits 1 on zero matches; every count is `; true`-terminated so a
#     legitimate ZERO cannot kill the loop.
set -u
export LC_ALL=C
A=${1:?patched wd}
B=${2:?pristine wd}
shift 2
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
OUT=${MV79OUT:-/tmp/r10uvm79_mv}
mkdir -p "$OUT" || exit 9
norm() { "$DUMP" "$1" 2>/dev/null | sed 1d | sed -E 's/, id:[0-9]+//g' |
         sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//'; }
tot=0; exact=0; notgold=0
for p in "$@"; do
  t=$(echo "$p" | tr '/.' '__')
  d=$(dirname "$A/$p")
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ]; then echo "NOGOLDEN $p"; continue; fi
  [ -f "$OUT/$t.pat" ]  || norm "$A/$p" | LC_ALL=C sort > "$OUT/$t.pat"
  [ -f "$OUT/$t.pris" ] || norm "$B/$p" | LC_ALL=C sort > "$OUT/$t.pris"
  [ -f "$OUT/$t.gold" ] || norm "$G"    | LC_ALL=C sort > "$OUT/$t.gold"
  cnt() { uniq -c "$1" | sed -E 's/^ +//' | LC_ALL=C sort; }
  cnt "$OUT/$t.pris" > "$OUT/$t.cpris"; cnt "$OUT/$t.pat" > "$OUT/$t.cpat"
  echo "== $p"
  { comm -23 "$OUT/$t.cpris" "$OUT/$t.cpat"; comm -13 "$OUT/$t.cpris" "$OUT/$t.cpat"; } |
  sed -E 's/^[0-9]+ //' | LC_ALL=C sort -u |
  while IFS= read -r shape; do
    g=$(grep -Fxc "$shape" "$OUT/$t.gold"; true)
    r=$(grep -Fxc "$shape" "$OUT/$t.pris"; true)
    a=$(grep -Fxc "$shape" "$OUT/$t.pat"; true)
    mark=""
    [ "$g" = "$a" ] || mark="   <== NOT-GOLDEN"
    echo "  g=$g pris=$r pat=$a$mark  $shape"
  done
done
