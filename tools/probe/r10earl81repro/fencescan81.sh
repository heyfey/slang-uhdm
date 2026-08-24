#!/usr/bin/env bash
# r10earl81 — CORPUS-WIDE scan for the family this pass moves and for the two
# families it must NOT move: for every database in a sweep workdir, join our
# .uhdm against the GOLDEN named by that test's OWN cmds.txt and count the
# port-High_conn SELECT cells by (slot, golden kind -> our kind).
#
# MEASUREMENT ONLY: it READS databases and DISPATCHES NOTHING, so no test —
# fenced or otherwise — is run by it.  FENCED= lists only.
#
#   usage: SELCEN81=<selcen81 binary> fencescan81.sh <sweep-workdir> <out.tsv>
set -u
CEN=${SELCEN81:?set SELCEN81}
HERE=$(dirname "$(readlink -f "$0")")
WD=$(readlink -f "$1"); OUT=$(readlink -f "$2")
T=${TMPDIR:-/tmp}/r10earl81_fs.$$
mkdir -p "$T"
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
  "$CEN" "$g"    2>/dev/null > "$T/g.cen" || continue
  "$CEN" "$ours" 2>/dev/null > "$T/o.cen" || continue
  line=$(python3 "$HERE/hcfam81.py" "$T/g.cen" "$T/o.cen" 2>/dev/null)
  printf '%s\t%s\n' "${d#$WD/}" "${line:-NONE}" >> "$OUT"
  n=$((n+1))
done < <(find "$WD" -name cmds.txt | sort)
rm -rf "$T"
echo "SCANNED=$n"
awk -F'\t' '{print $2}' "$OUT" | tr ';' '\n' | grep -v '^$' \
  | awk -F= '{s[$1]+=$2} END{for(k in s) printf "  %-46s %d\n", k, s[k]}' | sort -k2 -nr
echo "-- databases carrying the TARGET shape (bitsel-idx G=constant O=ref_obj) --"
grep 'BITSELIDX_G_CONST_O_REF' "$OUT" | sed 's/\t/  /' || true
