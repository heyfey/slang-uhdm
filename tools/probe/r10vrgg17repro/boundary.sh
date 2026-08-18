#!/usr/bin/env bash
# vrgg17 WIDE BOUNDARY — recursive over a COPY of tools/probe, no path filter,
# .sv and .v, PER-FILE and PER-DIRECTORY arms, BOTH views.
# Guards: file list on fd 3; children </dev/null; PROCESSED asserted == LISTED;
# rc recorded per cell; asymmetries loud; UNCOMPILABLE counted not skipped;
# the four slang-fenced tests are never dispatched.
set -u
A=${1:?base}; B=${2:?pat}; OUT=${3:?out}; ROOT=${4:?root}; VIEW=${5:-plain}
case $VIEW in plain) XF="";; elab) XF="--elabuhdm";; esac
same=0; diff=0; nocomp=0; asym=0; n=0
LIST=$(mktemp /tmp/vrgg17_bndlist.XXXXXX)
find "$ROOT" -type f \( -name '*.sv' -o -name '*.v' \) -not -path '*/slpp_all/*' \
  | grep -viE 'unsignedparam|hierpatheval|filelocalparam|topparam' | sort > "$LIST"
LISTED=$(wc -l < "$LIST")
{
echo "== PER-FILE, view=$VIEW, LISTED=$LISTED"
while IFS= read -r f <&3; do
  n=$((n+1))
  wa=/tmp/vrgg17_bnd_a.$$.uhdm; wb=/tmp/vrgg17_bnd_b.$$.uhdm
  rm -f "$wa" "$wb"
  (cd "$(dirname "$f")" && "$A" "$(basename "$f")" --single-unit $XF -o "$wa" >/dev/null 2>&1 </dev/null); ra=$?
  (cd "$(dirname "$f")" && "$B" "$(basename "$f")" --single-unit $XF -o "$wb" >/dev/null 2>&1 </dev/null); rb=$?
  if [ ! -f "$wa" ] && [ ! -f "$wb" ]; then echo "UNCOMPILABLE $f rc=$ra/$rb"; nocomp=$((nocomp+1))
  elif [ ! -f "$wa" ] || [ ! -f "$wb" ]; then echo "ASYMMETRY $f rc=$ra/$rb"; asym=$((asym+1))
  elif cmp -s "$wa" "$wb"; then same=$((same+1))
  else echo "MOVER $f rc=$ra/$rb"; diff=$((diff+1)); fi
  rm -f "$wa" "$wb"
done 3< "$LIST"
echo "-- PER-FILE view=$VIEW LISTED=$LISTED PROCESSED=$n identical=$same MOVERS=$diff uncompilable=$nocomp asymmetries=$asym"
[ "$n" = "$LISTED" ] || echo "!! PROCESSED != LISTED"
[ "$n" -gt 0 ] || echo "!! PROCESSED ZERO"
# ---- PER-DIRECTORY arms: every directory holding >=1 source, all its sources
DL=$(mktemp /tmp/vrgg17_bnddirs.XXXXXX)
cut -d/ -f1- "$LIST" | xargs -r -n1 dirname | sort -u > "$DL"
DLN=$(wc -l < "$DL"); dn=0; dsame=0; ddiff=0; dnoc=0; dasym=0
echo "== PER-DIR, view=$VIEW, LISTED=$DLN"
while IFS= read -r d <&3; do
  dn=$((dn+1))
  mapfile -t srcs < <(grep -F "$d/" "$LIST" | awk -F/ -v d="$d" '{p=$0; sub("/[^/]*$","",p); if(p==d) print}')
  [ ${#srcs[@]} -gt 0 ] || continue
  bn=(); for s in "${srcs[@]}"; do bn+=("$(basename "$s")"); done
  wa=/tmp/vrgg17_bndd_a.$$.uhdm; wb=/tmp/vrgg17_bndd_b.$$.uhdm; rm -f "$wa" "$wb"
  (cd "$d" && "$A" "${bn[@]}" --single-unit $XF -o "$wa" >/dev/null 2>&1 </dev/null); ra=$?
  (cd "$d" && "$B" "${bn[@]}" --single-unit $XF -o "$wb" >/dev/null 2>&1 </dev/null); rb=$?
  if [ ! -f "$wa" ] && [ ! -f "$wb" ]; then echo "DIR-UNCOMPILABLE $d rc=$ra/$rb"; dnoc=$((dnoc+1))
  elif [ ! -f "$wa" ] || [ ! -f "$wb" ]; then echo "DIR-ASYMMETRY $d rc=$ra/$rb"; dasym=$((dasym+1))
  elif cmp -s "$wa" "$wb"; then dsame=$((dsame+1))
  else echo "DIR-MOVER $d rc=$ra/$rb"; ddiff=$((ddiff+1)); fi
  rm -f "$wa" "$wb"
done 3< "$DL"
echo "-- PER-DIR view=$VIEW LISTED=$DLN PROCESSED=$dn identical=$dsame MOVERS=$ddiff uncompilable=$dnoc asymmetries=$dasym"
[ "$dn" = "$DLN" ] || echo "!! DIR PROCESSED != LISTED"
rm -f "$DL"
} > "$OUT" 2>&1
rm -f "$LIST"
tail -20 "$OUT"
