#!/usr/bin/env bash
# r10uvm60repro/szall60.sh — run the SPAN-FREE per-owner proof (szcmp60.py) for
# EVERY mover of a patched-vs-pristine sweep pair, so the size/typespec claim is
# made per MOVER and not once on a representative.
#
#   usage: szall60.sh <patched-workdir> <pristine-workdir> <outdir>
#
# GUARDS: the golden path comes from the test's OWN cmds.txt and a missing golden
# is GOLDEN_MISSING + exit 6; zero movers examined is exit 5 (a run that proved
# nothing must not read as a proof).
set -u
A=${1:?patched workdir}
B=${2:?pristine workdir}
OUT=${3:?outdir}
P=${ARGTS60B:-/tmp/r10uvm60/argts60b}
HERE=$(cd "$(dirname "$0")" && pwd)
[ -x "$P" ] || { echo "FATAL: no argts60b at $P"; exit 3; }
mkdir -p "$OUT" || exit 1
n=0
while read -r p; do
  cmp -s "$A/$p" "$B/$p" && continue
  n=$((n+1))
  d=$(dirname "$p"); key=$(echo "$d" | tr '/' '_')
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$B/$d/cmds.txt" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  [ -f "$G" ] || { echo "GOLDEN_MISSING $d"; exit 6; }
  "$P" "$G"     | grep -P "^CELL\tSIZECELL" > "$OUT/$key.gold"
  "$P" "$B/$p"  | grep -P "^CELL\tSIZECELL" > "$OUT/$key.pris"
  "$P" "$A/$p"  | grep -P "^CELL\tSIZECELL" > "$OUT/$key.pat"
  echo "===== MOVER $d"
  python3 "$HERE/szcmp60.py" "$OUT/$key.gold" "$OUT/$key.pris" "$OUT/$key.pat"
done < <(cd "$A" && find . -name slang.uhdm | sort)
echo "movers examined: $n"
[ "$n" -gt 0 ] || { echo "REFUSING TO REPORT: no movers examined"; exit 5; }
