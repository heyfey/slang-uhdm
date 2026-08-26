#!/usr/bin/env bash
# r10earl98 -- CORPUS POPULATION COUNT.  For every test directory of a
# verify_golden workdir, run ct98pop over (golden, ours) and print one line.
# The golden path is read out of the workdir's OWN cmds.txt, so this cannot
# silently score against the wrong golden.  Children get </dev/null.
# MEASUREMENT ONLY.
#   usage: pop98.sh <workdir-root> <out.txt>
#   env:   POP98 (path to the ct98pop binary)
set -u
WD=${1:?workdir}; OUT=${2:?out}
POP=${POP98:?}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
# FENCED: the four SLANG-FENCED test names are never dispatched and are never
# SPELLED in this directory (only canaudit.sh may name them).  The caller must
# supply them as an extended-regex in FENCE_RE; any test directory whose name
# MATCHES is skipped and reported only as a COUNT.  Note that a name may match
# as a SUBSTRING of an unrelated test -- that test is skipped too, deliberately,
# so that no artifact of this pass can carry the fenced spelling.
FENCE_RE=${FENCE_RE:?set FENCE_RE to the fenced-name alternation from the brief}
: > "$OUT"
n=0; skipped=0; fenced=0
while read -r c <&3; do
  d=$(dirname "$c")
  if echo "$(basename "$d")" | grep -qE "$FENCE_RE"; then
    fenced=$((fenced+1)); continue
  fi
  o="$d/slang.uhdm"
  g=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$c" | head -1)
  [ -n "$g" ] && [ -d "$g" ] && g="$g/golden.uhdm"
  if [ -z "$g" ] || [ ! -f "$g" ] || [ ! -f "$o" ]; then skipped=$((skipped+1)); continue; fi
  n=$((n+1))
  line=$("$POP" "$g" "$o" </dev/null 2>/dev/null | tail -1)
  echo "${d#$WD/} $line" >> "$OUT"
done 3< <(find "$WD" -name cmds.txt | sort)
echo "PAIRS=$n SKIPPED=$skipped FENCED=$fenced"
awk '{for(i=2;i<=NF;i++){split($i,a,"=");s[a[1]]+=a[2]}} END {printf "TOTALS "; for(k in s) printf "%s=%d ", k, s[k]; printf "\n"}' "$OUT"
