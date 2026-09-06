#!/usr/bin/env bash
# r10earl109 -- run cen109 over a verify_golden WORKDIR, golden side and ours.
# MEASUREMENT ONLY.
#   cenrun109.sh <workdir> <out.txt> [gold|ours]
# GUARDS:
#   * the golden path is read out of each test's OWN cmds.txt (never guessed);
#   * a missing side prints SKIP-NOFILE and is COUNTED -- a run that reaches
#     nothing must never read as perfection;
#   * every cen109 rc is asserted (CENRC) and a bad one is printed and counted;
#   * PROCESSED is asserted against LISTED at the end.
set -u
WD=${1:?workdir}
OUT=${2:?out}
SIDE=${3:-ours}
CEN=${CEN_BIN:-/tmp/r10earl109_cen109}
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
: > "$OUT"
listed=0; proc=0; miss=0; bad=0
while IFS= read -r c; do
  listed=$((listed+1))
  d=$(dirname "$c")
  n=$(basename "$d"); mode=$(basename "$(dirname "$d")")
  if [ "$SIDE" = gold ]; then
    G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$c" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && F=$G/golden.uhdm || F=""
  else
    F=$d/slang.uhdm
  fi
  if [ -z "${F:-}" ] || [ ! -f "$F" ]; then
    echo "SKIP-NOFILE $mode/$n" >> "$OUT"; miss=$((miss+1)); continue
  fi
  "$CEN" "$F" "${mode}__${n%%-*}" >> "$OUT" 2>>"$OUT.err"
  rc=$?
  [ "$rc" = 0 ] || { echo "CENRC-BAD $mode/$n rc=$rc" >> "$OUT"; bad=$((bad+1)); }
  proc=$((proc+1))
done < <(find "$WD" -name cmds.txt | sort)
echo "LISTED=$listed PROCESSED=$proc SKIP-NOFILE=$miss CENRC-BAD=$bad" >> "$OUT"
echo "LISTED=$listed PROCESSED=$proc SKIP-NOFILE=$miss CENRC-BAD=$bad"
[ $((proc+miss)) -eq "$listed" ] || { echo "PROCESSED-MISMATCH"; exit 4; }
