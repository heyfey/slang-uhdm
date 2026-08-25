set -u
ROOT=$1; OUT=$2
: > "$OUT"
n=0; hits=0
while read -r -u 3 c; do
  n=$((n+1))
  d=$(dirname "$c")
  g=$(grep -oE '/home/heyfey/\.cache/slang-uhdm-goldens/[0-9a-f]+' "$c" | head -1)
  [ -n "$g" ] || { g=$(grep -oE '\-o [^ ]*surelog\.uhdm' "$c" | head -1); }
  db="$g/golden.uhdm"
  [ -f "$db" ] || { echo "NODB	$d" >> "$OUT"; continue; }
  h=$(/tmp/v149_scratch/ctv149pred "$db" 2>/dev/null | tail -1 | cut -d' ' -f1)
  [ "${h:-0}" != 0 ] && { echo "CAND	$d	$h" >> "$OUT"; hits=$((hits+1)); }
done 3< <(find "$ROOT" -name cmds.txt | sort)
echo "SCANNED=$n CANDIDATE_ROWS=$hits"
