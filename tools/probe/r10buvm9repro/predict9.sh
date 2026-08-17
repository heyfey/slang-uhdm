#!/usr/bin/env bash
# r10buvm9repro/predict9.sh — NAME THE MOVERS BEFORE ANY BYTE IS COMPARED.
#
#   usage: predict9.sh <pristine_workdir_root> [outfile]
#
# Reads ONLY the PRISTINE databases (never the patched ones, never golden) and
# prints every object § sharedTdRefNoRestamp9 could possibly touch: a typespec
# that a listing OWNS and that our binary has STAMPED with a package —
#   RULE A  listed in a CLASS listing, stamped at all, and NOT a class_typespec
#           (golden gives a class_defn's typespecs no vpiInstance -- except a
#           class_typespec, whose owner § classKeyTsScopeOwner35 decides from
#           the LAST package listing to publish it, which is the ONE cell
#           § sharedTdRefNoRestamp9 deliberately does not claim);
#   RULE B  listed in a package's ELABORATED listing and stamped with a
#           DIFFERENT package object of the SAME NAME (the DEF twin).
# Both rules still OVER-predict -- a stamp written by a DECLARATION site or by a
# design-final pass looks identical here to one written by a reference site, and
# only the reference-site ones move.  Over-prediction is reported as such; a
# mover this script does not name is a FAILURE of the law's model.
#
# A run that reaches nothing must never read as perfection: databases visited,
# census failures and timeouts are all COUNTED and printed.
set -u
W=${1:?pristine workdir root}
O=${2:-/tmp/r10buvm9_predict.txt}
CEN=/tmp/r10buvm9cen
[ -x "$CEN" ] || { echo "FATAL: no census $CEN (run build9.sh)"; exit 3; }
[ -d "$W" ] || { echo "FATAL: no workdir $W"; exit 3; }
: > "$O"
n=0; fail=0; hit=0
while read -r db; do
  n=$((n+1))
  t=$(mktemp)
  if ! timeout 600 "$CEN" "$db" X > "$t" 2>/dev/null; then fail=$((fail+1)); rm -f "$t"; continue; fi
  if grep -q '^RESTORE_FAIL' "$t"; then fail=$((fail+1)); rm -f "$t"; continue; fi
  rel=${db#"$W"/}
  # RULE A
  awk -v rel="$rel" '$1=="TS" {
      iv=""; ls="";
      for(i=1;i<=NF;i++){ if($i ~ /^inst=/) iv=substr($i,6); if($i ~ /^listed=/) ls=substr($i,8) }
      if (ls ~ /CLS:/ && iv != "-" && $3 != "class_typespec") printf "CAND A %s %s %s %s inst=%s listed=%s\n", rel, $3, $4, $5, iv, ls
  }' "$t" >> "$O"
  # RULE B — an ELAB-listing entry whose stamp is a package object that is NOT
  # the package holding the listing.
  awk -v rel="$rel" '$1=="PKGTS" && $3=="ELAB" {
      pk=""; iv="";
      for(i=1;i<=NF;i++){ if($i ~ /^pkgid=/) pk=substr($i,7); if($i ~ /^inst=/) iv=substr($i,6) }
      if (iv != "-") { split(iv,q,"#"); if ("#" q[2] != pk) printf "CAND B %s %s %s inst=%s pkg=%s\n", rel, $7, $8, iv, pk }
  }' "$t" >> "$O"
  rm -f "$t"
done < <(find "$W" -name slang.uhdm | LC_ALL=C sort)
hit=$(awk '{print $3}' "$O" | sort -u | wc -l)
echo "predict9: databases=$n census_fail=$fail  candidate DATABASES=$hit  candidate OBJECTS=$(wc -l < "$O")"
[ "$n" -gt 0 ] || { echo "FATAL: reached NO databases"; exit 5; }
echo "-- candidate databases:"; awk '{print $3}' "$O" | sort -u | sed 's/^/   /'
echo "-- by rule:"; awk '{print $2}' "$O" | sort | uniq -c
echo "-> $O"
