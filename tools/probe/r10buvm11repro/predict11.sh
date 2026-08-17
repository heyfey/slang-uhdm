#!/usr/bin/env bash
# r10buvm11repro/predict11.sh — NAME THE MOVERS BEFORE ANY BYTE IS COMPARED.
#
#   usage: predict11.sh <pristine_workdir_root> [outfile]
#
# Reads ONLY the PRISTINE databases (never the patched ones, never golden) and
# prints, straight out of the object model, every object
# § bitElemSharesArrayRanges11 can possibly touch:
#
#   CAND A  an `array_var` whose vpiReg element is a `bit_var`, whose own
#           `Ranges()` is NON-EMPTY, whose element has NO ranges, and whose
#           parent chain contains a `class_defn` -> the law WILL stamp it.
#   CAND B  the SAME SHAPE with NO class_defn in the chain (a module- or
#           package-scope array_var) -> the law must NOT reach it.  CAND B is a
#           CONTROL, not a prediction: every CAND B object that moves is an
#           over-fire.
#
# A run that reaches nothing must never read as perfection: databases visited,
# census failures and restore failures are all COUNTED and printed, and a run
# that reached zero databases is FATAL.
set -u
W=${1:?pristine workdir root}
O=${2:-/tmp/r10buvm11_predict.txt}
CEN=/tmp/r10buvm11cen
[ -x "$CEN" ] || { echo "FATAL: no census $CEN (run build11.sh)"; exit 3; }
[ -d "$W" ] || { echo "FATAL: no workdir $W"; exit 3; }
: > "$O"
n=0; fail=0
while read -r db; do
  n=$((n+1))
  t=$(mktemp)
  if ! timeout 1800 "$CEN" "$db" X > "$t" 2>/dev/null; then fail=$((fail+1)); rm -f "$t"; continue; fi
  if grep -q '^RESTORE_FAIL' "$t"; then fail=$((fail+1)); rm -f "$t"; continue; fi
  rel=${db#"$W"/}
  awk -v rel="$rel" '
    $1=="AV" {
      key=""; avr=""; ek=""; evr="";
      for(i=1;i<=NF;i++){
        if($i ~ /^key=/) key=substr($i,5);
        else if($i ~ /^avR=/) avr=substr($i,5)+0;
        else if($i ~ /^ek=/)  ek=substr($i,4);
        else if($i ~ /^evR=/) evr=substr($i,5)+0 }
      if (ek != "bit_var") next
      if (avr < 1) next
      if (evr >= 1) next
      if (key ~ /class_defn\(/) printf "CAND A %s %s\n", rel, key
      else                      printf "CAND B %s %s\n", rel, key
    }' "$t" >> "$O"
  rm -f "$t"
done < <(find "$W" -name slang.uhdm | LC_ALL=C sort)
echo "predict11: databases=$n census_fail=$fail  candidate OBJECTS=$(wc -l < "$O")"
[ "$n" -gt 0 ] || { echo "FATAL: reached NO databases"; exit 5; }
echo "-- CAND A databases ($(awk '$2=="A"{print $3}' "$O" | sort -u | wc -l)):"
awk '$2=="A"{print $3}' "$O" | sort | uniq -c | sed 's/^/   /'
echo "-- CAND B databases ($(awk '$2=="B"{print $3}' "$O" | sort -u | wc -l)):"
awk '$2=="B"{print $3}' "$O" | sort | uniq -c | sed 's/^/   /'
echo "-- by rule:"; awk '{print $2}' "$O" | sort | uniq -c
echo "-> $O"
