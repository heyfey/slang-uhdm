#!/usr/bin/env bash
# r10v187 -- THREE-WAY WHOLE-DUMP SCORE for one arm workdir and one view.
# MEASUREMENT ONLY; the official uhdm-cmp is the judge.
# LHS is ALWAYS golden.  Dumps are path-normalised, id-stripped and SORTED, so
# the score is ORDER-BLIND (the coin law).  Reports, as multisets of dump lines:
#   TOWARD  lines golden has that PATCHED has and PRISTINE did not
#   AWAY    lines golden has that PRISTINE had and PATCHED does not   <- must be 0
#   NOISE+  lines golden does NOT have that only PATCHED has
#   NOISE-  lines golden does NOT have that only PRISTINE had
#   usage: v187_dump3.sh <arm workdir> <def|elab>
set -u
W=$(readlink -f "${1:?arm workdir}"); V=${2:?def|elab}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
G="$W/g_$V/slpp_all/surelog.uhdm"; A="$W/a_$V.uhdm"; B="$W/b_$V.uhdm"
for f in "$G" "$A" "$B"; do
  [ -f "$f" ] || { echo "MISSING $f"; exit 3; }
done
norm() {  # strip ids, file paths and the dump's own header; sort
  "$DUMP" "$1" 2>/dev/null |
    sed -e 's#, id:[0-9]*##g' -e 's#file:[^,]*/#file:#g' -e '1d' |
    sort
}
t=$(mktemp -d /tmp/v187_d3.XXXXXX)
norm "$G" > "$t/g"; norm "$A" > "$t/a"; norm "$B" > "$t/b"
# multiset differences
ms() { comm -13 <(sort "$1") <(sort "$2"); }
onlyB=$(comm -13 "$t/a" "$t/b" | wc -l)     # patched has, pristine lacks
onlyA=$(comm -23 "$t/a" "$t/b" | wc -l)     # pristine has, patched lacks
towrd=$(comm -12 <(comm -13 "$t/a" "$t/b") "$t/g" | wc -l)
away=$(comm -12 <(comm -23 "$t/a" "$t/b") "$t/g" | wc -l)
noisep=$(comm -23 <(comm -13 "$t/a" "$t/b") "$t/g" | wc -l)
noisem=$(comm -23 <(comm -23 "$t/a" "$t/b") "$t/g" | wc -l)
printf "%-34s %-5s GOLD=%-6s PRIS=%-6s PAT=%-6s  +only=%-4s -only=%-4s TOWARD=%-4s AWAY=%-4s NOISE+=%-4s NOISE-=%s\n" \
  "$(basename "$W")" "$V" "$(wc -l < "$t/g")" "$(wc -l < "$t/a")" "$(wc -l < "$t/b")" \
  "$onlyB" "$onlyA" "$towrd" "$away" "$noisep" "$noisem"
if [ "${SHOWAWAY:-0}" = 1 ] && [ "$away" != 0 ]; then
  echo "---- AWAY lines (golden has them, pristine had them, patched lost them):"
  comm -12 <(comm -23 "$t/a" "$t/b") "$t/g" | head -40
fi
rm -rf "$t"
