#!/usr/bin/env bash
# r10v144 (VERIFIER) — score ONE arm dir with the WHOLE-DUMP ref_obj binding
# census (v144scan.py), both views: how many REF rows of GOLDEN each producer
# fails to reproduce, and the surviving rows.  MEASUREMENT ONLY.
#   usage: v144score.sh <armdir>
set -u
export LC_ALL=C
D=$(readlink -f "${1:?armdir}")
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
SC=$(dirname "$(readlink -f "$0")")/v144scan.py
for f in g o q ge oe qe; do
  [ -f "$D/$f.uhdm" ] || continue
  "$DUMP" "$D/$f.uhdm" > "$D/$f.dump" 2>/dev/null
  python3 "$SC" "$D/$f.dump" > "$D/$f.refs"
done
for v in "g o q DEF" "ge oe qe ELAB"; do
  set -- $v
  [ -f "$D/$1.refs" ] || continue
  n=$(grep -c '^REF' "$D/$1.refs"; true)
  pm=$(comm -23 "$D/$1.refs" "$D/$2.refs" | wc -l)
  qm=$(comm -23 "$D/$1.refs" "$D/$3.refs" | wc -l)
  pe=$(comm -13 "$D/$1.refs" "$D/$2.refs" | wc -l)
  qe=$(comm -13 "$D/$1.refs" "$D/$3.refs" | wc -l)
  echo "$4 goldenrows=$n  PRIS missing=$pm extra=$pe  PATCHED missing=$qm extra=$qe"
  comm -3 "$D/$2.refs" "$D/$3.refs" | sed "s/^/$4 PRIS-vs-PAT /"
done
