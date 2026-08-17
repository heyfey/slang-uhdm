#!/usr/bin/env bash
# r10buvm10repro/predict10.sh — NAME THE MOVERS BEFORE ANY BYTE IS COMPARED.
#
#   usage: predict10.sh <pristine_workdir_root> [outfile]
#
# Reads ONLY the PRISTINE databases (never the patched ones, never golden) and
# prints every object § enumBaseTdAliasClone10 / § enumBaseTdChainNoClone10 can
# possibly touch, straight out of the object model:
#
#   CAND A  a NAMED bit_/logic_typespec that is the Actual_typespec of a
#           ref_typespec whose PARENT is an enum_typespec and that carries NO
#           Typedef_alias  -> the alias-clone cell (the law ADDS an alias)
#   CAND B  the same edge where the actual's name is QUALIFIED ("::") and it
#           DOES carry an alias -> a candidate for the CHAIN cell (the law
#           REBINDS the base to the listing object and mints no clone)
#
# Both rules OVER-predict on purpose: CAND A cannot tell a base minted from a
# typedef NAME from one minted from a bare vector, and CAND B cannot tell a
# chained typedef from a plain qualified one.  Over-prediction is reported as
# such; a mover this script does NOT name is a FAILURE of the law's model.
#
# A run that reaches nothing must never read as perfection: databases visited,
# census failures and restore failures are all COUNTED and printed.
set -u
W=${1:?pristine workdir root}
O=${2:-/tmp/r10buvm10_predict.txt}
CEN=/tmp/r10buvm10cen
[ -x "$CEN" ] || { echo "FATAL: no census $CEN (run build10.sh)"; exit 3; }
[ -d "$W" ] || { echo "FATAL: no workdir $W"; exit 3; }
: > "$O"
n=0; fail=0
while read -r db; do
  n=$((n+1))
  t=$(mktemp)
  if ! timeout 900 "$CEN" "$db" X > "$t" 2>/dev/null; then fail=$((fail+1)); rm -f "$t"; continue; fi
  if grep -q '^RESTORE_FAIL' "$t"; then fail=$((fail+1)); rm -f "$t"; continue; fi
  rel=${db#"$W"/}
  awk -v rel="$rel" '
    $1=="REF" {
      ts=""; ha=""; ch="";
      for(i=1;i<=NF;i++){
        if($i ~ /^ts=/) ts=substr($i,4);
        else if($i ~ /^hasalias=/) ha=substr($i,10);
        else if($i ~ /^chain=/) ch=substr($i,7) }
      if (ch !~ /^enum_typespec\(/) next
      if (ts !~ /^(bit|logic)_typespec:/) next
      nm=ts; sub(/^[a-z_]*:/,"",nm); sub(/:#[0-9]+$/,"",nm)
      if (nm=="<anon>") next
      if (ha=="0" && nm !~ /::/) printf "CAND A %s %s %s\n", rel, ts, ch
      if (ha=="1" && nm ~ /::/)  printf "CAND B %s %s %s\n", rel, ts, ch
    }' "$t" >> "$O"
  rm -f "$t"
done < <(find "$W" -name slang.uhdm | LC_ALL=C sort)
echo "predict10: databases=$n census_fail=$fail  candidate OBJECTS=$(wc -l < "$O")"
[ "$n" -gt 0 ] || { echo "FATAL: reached NO databases"; exit 5; }
echo "-- candidate DATABASES ($(awk '{print $3}' "$O" | sort -u | wc -l)):"
awk '{print $3}' "$O" | sort -u | sed 's/^/   /'
echo "-- by rule:"; awk '{print $2}' "$O" | sort | uniq -c
echo "-> $O"
