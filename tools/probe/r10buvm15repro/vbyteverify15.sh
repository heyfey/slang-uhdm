#!/usr/bin/env bash
# vbuvm15 VERIFIER byte comparator (r10oth4's, carried forward unchanged in
# substance) with BOTH negative controls.
#   usage: [SELFCHECK=1] [SELFCHECK1=1] byteverify.sh <A root> <B root>
set -u
A=${1:?A}; B=${2:?B}
[ -d "$A" ] && [ -d "$B" ] || { echo NO_WORKDIR; exit 6; }
la=$(mktemp); lb=$(mktemp)
(cd "$A" && find . -name slang.uhdm | sort) > "$la"
(cd "$B" && find . -name slang.uhdm | sort) > "$lb"
na=$(wc -l < "$la"); nb=$(wc -l < "$lb")
echo "databases: A=$na B=$nb"
diff -q "$la" "$lb" >/dev/null || { echo PATH_SETS_DIFFER; diff "$la" "$lb"|head -20; exit 4; }
[ "$na" -gt 0 ] || { echo NO_DATABASES; exit 6; }
echo "PATH_SETS_IDENTICAL ($na paths)"
movers=0
while read -r p; do
  cmp -s "$A/$p" "$B/$p" || { echo "MOVER $p"; movers=$((movers+1)); }
done < "$la"
echo "MOVERS: $movers / $na"
if [ "${SELFCHECK:-0}" = 1 ]; then
  ref=$(head -1 "$la"); bad=0
  while read -r p; do cmp -s "$A/$p" "$B/$ref" || bad=$((bad+1)); done < "$la"
  echo "SELFCHECK (every file vs one fixed file): $bad / $na flagged"
  [ "$bad" -ge $((na-1)) ] || { echo SELFCHECK_FAILED; exit 5; }
fi
if [ "${SELFCHECK1:-0}" = 1 ]; then
  tmp=$(mktemp -d /tmp/vbuvm15_sc1_XXXX)
  (cd "$B" && tar cf - .) | (cd "$tmp" && tar xf -)
  victim=$(head -1 "$la")
  printf 'X' | dd of="$tmp/$victim" bs=1 seek=0 conv=notrunc status=none
  n1=0
  while read -r p; do cmp -s "$A/$p" "$tmp/$p" || n1=$((n1+1)); done < "$la"
  echo "SELFCHECK1 (one file corrupted): $n1  (expect movers+1)"
  rm -rf "$tmp"
fi
rm -f "$la" "$lb"
