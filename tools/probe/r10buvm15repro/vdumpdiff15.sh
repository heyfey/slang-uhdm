#!/usr/bin/env bash
# vbuvm15 VERIFIER attribution — WHOLE-DUMP, PATH-NORMALISED diff of one
# database between two workdirs.  Dump paths embed the workdir, so the two
# roots are normalised out before the diff; the SORTED diff is printed too
# because the campaign's Scoreboard row is a documented ORDER COIN and must be
# attributed ORDER-BLIND.
#   usage: dumpdiff.sh <A root> <B root> <relative path to slang.uhdm>
set -u
A=${1:?A}; B=${2:?B}; P=${3:?rel path}
D=$HOME/git-repos/UHDM/build/bin/uhdm-dump
[ -f "$A/$P" ] && [ -f "$B/$P" ] || { echo "MISSING SIDE"; exit 3; }
ta=$(mktemp); tb=$(mktemp)
"$D" "$A/$P" 2>&1 | sed "s#$A##g; s#$B##g" > "$ta"
"$D" "$B/$P" 2>&1 | sed "s#$A##g; s#$B##g" > "$tb"
echo "== $P  rawdiff_sides=$(diff "$ta" "$tb" | grep -cE '^[<>]'; true)  sorteddiff_sides=$(diff <(LC_ALL=C sort "$ta") <(LC_ALL=C sort "$tb") | grep -cE '^[<>]'; true)"
echo "-- SORTED diff (order-blind):"
diff <(LC_ALL=C sort "$ta") <(LC_ALL=C sort "$tb") | grep -E '^[<>]' | sed 's/^/   /' | head -60
rm -f "$ta" "$tb"
