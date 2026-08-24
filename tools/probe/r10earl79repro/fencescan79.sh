#!/usr/bin/env bash
# r10earl79 — CORPUS CENSUS + MOVER PREDICTION, read ENTIRELY out of the
# databases a sweep has ALREADY produced (golden from the immutable cache named
# by each test's own cmds.txt, ours from the sweep workdir).  It dispatches
# NOTHING, so no test — fenced or otherwise — is ever run by it.
# MEASUREMENT ONLY.
#   usage: DIMSCAN79=<bin> DIMJOIN79=<py> fencescan79.sh <sweep-workdir> <out-prefix>
set -u
S=${DIMSCAN79:?set DIMSCAN79}; J=${DIMJOIN79:?set DIMJOIN79}
W=${1:?sweep workdir}; O=${2:?out prefix}
: > "$O.raw"; n=0; withg=0
while IFS= read -r db; do
  n=$((n+1)); d=$(dirname "$db")
  gp=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' "$d/cmds.txt" 2>/dev/null | head -1)
  [ -n "$gp" ] && [ -f "$gp/golden.uhdm" ] || continue
  withg=$((withg+1))
  "$S" "$gp/golden.uhdm" > "$O.g.tmp" 2>/dev/null || continue
  "$S" "$db"             > "$O.o.tmp" 2>/dev/null || continue
  python3 "$J" "$O.g.tmp" "$O.o.tmp" | sed "s#^#$d | #"
done < <(find "$W" -name 'slang.uhdm' -print | sort) >> "$O.raw"
rm -f "$O.g.tmp" "$O.o.tmp"
{
  echo "DATABASES_SCANNED=$n"
  echo "PAIRS_WITH_GOLDEN=$withg"
  for f in EXPR EXPR_AGREE EXPR_DIFFER EXPR_SZ EXPR_CT EXPR_VAL EXPR_DEC \
           NAME NAME_AGREE NAME_DIFFER; do
    printf '%-12s cells=%s\n' "$f" \
      "$(awk -v k="$f" '$3==k{s+=$4} END{print s+0}' "$O.raw")"
  done
  echo "DBS_WITH_EXPR_CELLS=$(awk '$3=="EXPR" && $4>0{print $1}' "$O.raw" | sort -u | wc -l)"
  echo "DBS_WITH_EXPR_DIFFER=$(awk '$3=="EXPR_DIFFER" && $4>0{print $1}' "$O.raw" | sort -u | wc -l)"
  echo "DBS_WITH_NAME_DIFFER=$(awk '$3=="NAME_DIFFER" && $4>0{print $1}' "$O.raw" | sort -u | wc -l)"
} > "$O.tally"
cat "$O.tally"
