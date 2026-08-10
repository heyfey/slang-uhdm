#!/bin/bash
# exid26.sh <baseTag> <newTag> -- ROW-SET DELTA of two exi26 existence censuses.
# The totals alone hide direction: a law that removes one object we should not
# have and adds another we should can leave the count flat, and a law that only
# RESHAPES an object shows up on BOTH sides.  `<` = only in base, `>` = only in
# new.
grep '^DIFF' "/tmp/r10earl26_exi_$1.txt" | sort > /tmp/r10earl26_ex1.txt
grep '^DIFF' "/tmp/r10earl26_exi_$2.txt" | sort > /tmp/r10earl26_ex2.txt
echo "rows: $1=$(wc -l < /tmp/r10earl26_ex1.txt)  $2=$(wc -l < /tmp/r10earl26_ex2.txt)"
diff /tmp/r10earl26_ex1.txt /tmp/r10earl26_ex2.txt > /tmp/r10earl26_exd.txt
echo "removed: $(grep -c '^<' /tmp/r10earl26_exd.txt)  added: $(grep -c '^>' /tmp/r10earl26_exd.txt)"
echo "--- added row types"
grep '^>' /tmp/r10earl26_exd.txt | awk '{print $4, $5}' | sort | uniq -c | sort -rn | head -20
echo "--- removed row types"
grep '^<' /tmp/r10earl26_exd.txt | awk '{print $4, $5}' | sort | uniq -c | sort -rn | head -20
echo "--- full delta (first 60)"
head -60 /tmp/r10earl26_exd.txt
