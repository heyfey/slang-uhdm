#!/bin/bash
# r10uvm55repro/dumpdist.sh — the DUMP CONTENT DISTANCE of an already-dumped
# row, under BOTH of this campaign's two conventions, so a number from one pass
# can be compared with a number from another WITHOUT guessing.
#
#   usage: dumpdist.sh <outdir-with-g.dump-and-o.dump>
#
# CONVENTION A ("raw"),  as r10uvm55repro/wdump.sh reports it: dumps passed
#   through `sed '1d'` ONLY (uhdm-dump's first line is the database path).
# CONVENTION B ("scrubbed"), as r10uvm5xrepro/gold.sh reports it: additionally
#   `sed 's#/home/[^ ,]*/##g'`, which deletes every absolute path PREFIX and so
#   also collapses real file-attribution differences.
# Both are printed as RAW minus 2, the 2 being ONLY the `diff -u` header lines.
#
# GUARD: a missing or empty g.dump/o.dump is exit 6, never "0 difference".
set -u
D=${1:?outdir containing g.dump and o.dump}
[ -s "$D/g.dump" ] || { echo "NO_OUTPUT: $D/g.dump missing/empty"; exit 6; }
[ -s "$D/o.dump" ] || { echo "NO_OUTPUT: $D/o.dump missing/empty"; exit 6; }
A=$(diff -u "$D/g.dump" "$D/o.dump" | grep -c '^[-+]')
# SPLIT the distance into GOLDEN-ONLY and OURS-ONLY lines.  A whole-file line
# diff is a ROUGH distance: inserting a few objects can make `diff` pick a
# different LCS and RESYNCHRONISE over a large region, which shows up as BOTH
# counts rising together while the file grew by only a few lines.  Reporting the
# halves separately is what tells that apart from real added content.
AM=$(diff -u "$D/g.dump" "$D/o.dump" | grep -c '^-')
AP=$(diff -u "$D/g.dump" "$D/o.dump" | grep -c '^+')
echo "$D  golden-only=$((AM-1))  ours-only=$((AP-1))  (each minus its 1 diff -u header line)"
echo "$D  g.dump lines=$(wc -l < "$D/g.dump")  o.dump lines=$(wc -l < "$D/o.dump")"
sed 's#/home/[^ ,]*/##g' "$D/g.dump" > "$D/g.scrub"
sed 's#/home/[^ ,]*/##g' "$D/o.dump" > "$D/o.scrub"
B=$(diff -u "$D/g.scrub" "$D/o.scrub" | grep -c '^[-+]')
echo "$D  convA(raw)=$((A-2))  convB(path-scrubbed)=$((B-2))"
