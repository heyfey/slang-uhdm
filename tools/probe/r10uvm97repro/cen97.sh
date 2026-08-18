#!/usr/bin/env bash
# r10uvm97 — run ct97cen over a whole verify_golden workdir, GOLDEN and OURS
# side by side, and join.  MEASUREMENT ONLY.
#   ./cen97.sh <workdir> <outdir> [name-regex]
# For every <mode>/<test>-<hash>/ that has both a golden (read out of the
# workdir's OWN cmds.txt, so the wrong golden can never be compared) and a
# slang.uhdm, writes <outdir>/<mode>.<test>.{g,o}.cen and one JOIN line.
# LHS is ALWAYS golden.
set -u
WD=${1:?workdir}; OUT=${2:?outdir}; PAT=${3:-}   # empty PAT = every test (a `.` would
                                              # match only names WITH a dot)
CEN=${CEN:-/tmp/r10uvm97_ct97cen}
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
mkdir -p "$OUT" || exit 1
: > "$OUT/JOIN.txt"
for d in "$WD"/*/*/; do
  mode=$(basename "$(dirname "$d")")
  test=$(basename "$d")
  case "$test" in *$PAT*) ;; *) continue ;; esac
  O="$d/slang.uhdm"; C="$d/cmds.txt"
  [ -f "$O" ] || continue
  [ -f "$C" ] || continue
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  [ -n "$G" ] && [ -f "$G" ] || continue
  "$CEN" "$G" > "$OUT/$mode.$test.g.cen" 2>/dev/null
  "$CEN" "$O" > "$OUT/$mode.$test.o.cen" 2>/dev/null
  python3 "$(dirname "$0")/join97.py" "$mode/$test" \
      "$OUT/$mode.$test.g.cen" "$OUT/$mode.$test.o.cen" >> "$OUT/JOIN.txt"
done
echo "JOIN rows: $(wc -l < "$OUT/JOIN.txt")"
