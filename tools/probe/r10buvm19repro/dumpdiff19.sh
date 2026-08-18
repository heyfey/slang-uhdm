#!/usr/bin/env bash
# r10buvm19repro/dumpdiff19.sh — attribute a byte mover to its LINES.
# Dumps both databases, normalises the uhdm-dump banner and the workdir paths
# (dump paths embed the workdir) and object ids, and reports the diff BOTH raw
# and ORDER-BLIND (sorted), because Scoreboard/default is a documented ~50/50
# vpiTaskFunc ORDER coin and only the order-blind count attributes it.
#
# usage: dumpdiff19.sh <pristine.uhdm> <patched.uhdm> [outdir]
set -u
P=$1; Q=$2; O=${3:-/tmp/r10buvm19_dd}
mkdir -p "$O"
norm() { sed -e '1s#^[^:]*\.uhdm:#<DB>:#' -e 's#/tmp/[A-Za-z0-9_]*_wd_[A-Za-z]*/#<WD>/#g' \
             -e 's#, id:[0-9]*##g'; }
uhdm-dump "$P" 2>&1 | norm > "$O/p.txt"
uhdm-dump "$Q" 2>&1 | norm > "$O/q.txt"
raw=$(diff "$O/p.txt" "$O/q.txt" | grep -c '^[<>]'; true)
sort "$O/p.txt" > "$O/p.s"; sort "$O/q.txt" > "$O/q.s"
srt=$(diff "$O/p.s" "$O/q.s" | grep -c '^[<>]'; true)
echo "RAW-SIDES=$raw SORTED-SIDES=$srt"
diff "$O/p.txt" "$O/q.txt" > "$O/diff.txt" 2>&1
echo "-- added (patched only), sorted-unique:"
diff "$O/p.s" "$O/q.s" | grep '^>' | sed 's/^> //' | sort | uniq -c | sort -rn | head -20
echo "-- removed (pristine only), sorted-unique:"
diff "$O/p.s" "$O/q.s" | grep '^<' | sed 's/^< //' | sort | uniq -c | sort -rn | head -20
