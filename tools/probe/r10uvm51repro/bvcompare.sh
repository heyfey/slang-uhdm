#!/bin/bash
# r10uvm51repro/bvcompare.sh — the other half of the BYTE VERIFIER: join two
# manifests produced by manifest.sh and report identical / DIFFER, naming every
# mover.
#
# *** SCOREBOARD IS EXCLUDED FROM ANY IDENTITY CLAIM. *** Pass 41 measured
# `Scoreboard`'s `default` database as NONDETERMINISTIC run-to-run on EVERY
# binary (recorded macro-buffer SourceLocation flake, PRE-EXISTING), so a
# Scoreboard byte difference is NEVER evidence of a change.  Its rows are split
# out below rather than filtered away.
#
#   usage: bvcompare.sh <head-manifest> <post-manifest>
#
# GUARD: a zero PAIRED count is a hard error — joining two manifests that share
# no path reports "0 differ", the failure that reads as perfection.
set -u
H=${1:?head manifest}
P=${2:?post manifest}
T=$(mktemp -d)
join -j 2 -o 1.2,1.1,2.1 <(sort -k2 "$H") <(sort -k2 "$P") > "$T/join.txt"
echo "  head databases: $(wc -l < "$H")"
echo "  post databases: $(wc -l < "$P")"
echo "  paired:         $(wc -l < "$T/join.txt")"
[ "$(wc -l < "$T/join.txt")" -gt 0 ] || {
  echo "REFUSING TO REPORT: the two manifests share no path"; exit 5; }
awk '$2==$3' "$T/join.txt" > "$T/same.txt"
awk '$2!=$3' "$T/join.txt" > "$T/diff.txt"
echo "  identical:      $(wc -l < "$T/same.txt")"
echo "  DIFFER:         $(wc -l < "$T/diff.txt")"
grep -i scoreboard "$T/diff.txt" | cut -d' ' -f1 | sed 's/^/    [NOT EVIDENCE] /'
grep -iv scoreboard "$T/diff.txt" | cut -d' ' -f1 | sed 's/^/    MOVER /'
comm -3 <(cut -d'	' -f2 "$H" 2>/dev/null | sed 's/.*  //' | sort) \
        <(sed 's/.*  //' "$P" | sort) 2>/dev/null | head -20
rm -rf "$T"
