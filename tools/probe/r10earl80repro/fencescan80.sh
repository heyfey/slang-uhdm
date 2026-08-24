#!/usr/bin/env bash
# r10earl80 — CORPUS-WIDE param_assign census: for every database in a sweep
# workdir, join our .uhdm against the GOLDEN named by that test's own cmds.txt
# and count the DECOMPILE-WIDTH cells (§ ovHopOverriddenKeepsValue80's family).
#
# MEASUREMENT ONLY: it READS databases and DISPATCHES NOTHING, so no test —
# fenced or otherwise — is run by it.  FENCED= lists only.
#   usage: PACEN80=.. fencescan80.sh <sweep-workdir> <out.tsv>
set -u
CEN=${PACEN80:?set PACEN80}
HERE=$(dirname "$(readlink -f "$0")")
WD=$(readlink -f "$1"); OUT=$(readlink -f "$2")
: > "$OUT"
n=0
while IFS= read -r c; do
  d=$(dirname "$c")
  ours="$d/slang.uhdm"
  [ -f "$ours" ] || continue
  g=$(grep -o '/home/[^ )]*golden.uhdm' "$c" | head -1)
  if [ -z "$g" ]; then
    g=$(grep -o 'goldens/[0-9a-f]*' "$c" | head -1)
    [ -n "$g" ] && g="$HOME/.cache/slang-uhdm-$g/golden.uhdm"
  fi
  [ -n "$g" ] && [ -f "$g" ] || continue
  "$CEN" "$g"    2>/dev/null > /tmp/r10earl80_fs_g.pa || continue
  "$CEN" "$ours" 2>/dev/null > /tmp/r10earl80_fs_o.pa || continue
  line=$(python3 "$HERE/fam80.py" /tmp/r10earl80_fs_g.pa /tmp/r10earl80_fs_o.pa --shapes 0 \
          2>/dev/null | awk '/^  [A-Z]/{printf "%s=%s;", $1, $2}')
  printf '%s\t%s\n' "${d#$WD/}" "${line:-NONE}" >> "$OUT"
  n=$((n+1))
done < <(find "$WD" -name cmds.txt | sort)
echo "SCANNED=$n"
awk -F'\t' '{print $2}' "$OUT" | tr ';' '\n' | grep -v '^$' | awk -F= '{s[$1]+=$2} END{for(k in s) printf "  %-30s %d\n", k, s[k]}' | sort -k2 -nr
echo "-- databases with DECOMPILE-WIDTH cells --"
grep 'DECOMPILE-WIDTH' "$OUT" | sed 's/\t/  /' || true
