#!/usr/bin/env bash
# ORDER-BLIND attribution of one mover: sorted, path-normalised uhdm-dump diff.
set -u
D=$HOME/git-repos/UHDM/build/bin/uhdm-dump
REL="$1"
P=${PRIS_WD:?set PRIS_WD}/$REL; Q=${PAT_WD:?set PAT_WD}/$REL
for f in "$P" "$Q"; do
  "$D" "$f" 2>/dev/null | sed -E 's/, id:[0-9]+//g; s/id:[0-9]+//g; s#'"$PRIS_WD"'|'"$PAT_WD"'##g' | sed -E 's/^[[:space:]]+//' | sort
done > /dev/null
"$D" "$P" 2>/dev/null | sed -E 's/, id:[0-9]+//g; s/id:[0-9]+//g; s#'"$PRIS_WD"'|'"$PAT_WD"'##g' | sed -E 's/^[[:space:]]+//' | sort > ${TMPDIR:-/tmp}/r10v136_attr_p.txt
"$D" "$Q" 2>/dev/null | sed -E 's/, id:[0-9]+//g; s/id:[0-9]+//g; s#'"$PRIS_WD"'|'"$PAT_WD"'##g' | sed -E 's/^[[:space:]]+//' | sort > ${TMPDIR:-/tmp}/r10v136_attr_q.txt
echo "== $REL"
diff ${TMPDIR:-/tmp}/r10v136_attr_p.txt ${TMPDIR:-/tmp}/r10v136_attr_q.txt | grep -E '^[<>]' | sort | uniq -c | sort -rn | head -20
echo "   OUT=$(diff ${TMPDIR:-/tmp}/r10v136_attr_p.txt ${TMPDIR:-/tmp}/r10v136_attr_q.txt | grep -c '^<'; true) IN=$(diff ${TMPDIR:-/tmp}/r10v136_attr_p.txt ${TMPDIR:-/tmp}/r10v136_attr_q.txt | grep -c '^>'; true)"
