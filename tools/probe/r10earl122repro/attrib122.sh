#!/usr/bin/env bash
# r10earl122 — ATTRIBUTE one byte mover, path-normalised and ORDER-BLIND.
#
# MEASUREMENT ONLY.  `uhdm-cmp` is the judge.
#
# Two dumps of the same design differ for two very different reasons and the
# gate must tell them apart (RESUME.md §9): a REAL change (content lines
# appear or disappear) and ARENA ORDER (the same lines in another order, the
# documented ~50/50 coin).  So the diff is run RAW and again on both sides
# SORTED; a mover whose SORTED diff is empty changed nothing the judge reads.
#
# The dump paths embed the workdir, so both sides are normalised first.
#
# usage: attrib122.sh <pristine.uhdm> <patched.uhdm> <out-prefix>
set -u
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
P=${1:?pristine db}; X=${2:?patched db}; OUT=${3:?out prefix}
"$DUMP" "$P" 2>/dev/null | sed '1d' | sed 's#/tmp/r10earl122_wd[PX0-9]*#WD#g' > "$OUT.p"
"$DUMP" "$X" 2>/dev/null | sed '1d' | sed 's#/tmp/r10earl122_wd[PX0-9]*#WD#g' > "$OUT.x"
echo "lines pristine=$(wc -l < "$OUT.p")  patched=$(wc -l < "$OUT.x")"
echo "RAW diff lines        : $(diff "$OUT.p" "$OUT.x" | grep -c '^[<>]' ; true)"
sort "$OUT.p" > "$OUT.ps"; sort "$OUT.x" > "$OUT.xs"
echo "ORDER-BLIND diff lines: $(diff "$OUT.ps" "$OUT.xs" | grep -c '^[<>]' ; true)"
echo "--- ORDER-BLIND added/removed by leading token:"
diff "$OUT.ps" "$OUT.xs" | grep '^>' | sed 's/^> *//' | awk '{print $1}' |
  sort | uniq -c | sort -rn | head -20 | sed 's/^/  ADDED   /'
diff "$OUT.ps" "$OUT.xs" | grep '^<' | sed 's/^< *//' | awk '{print $1}' |
  sort | uniq -c | sort -rn | head -20 | sed 's/^/  REMOVED /'
