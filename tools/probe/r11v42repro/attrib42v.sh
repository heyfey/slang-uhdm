#!/usr/bin/env bash
# r11v42 — order-blind, path-normalised dump attribution for ONE mover path.
#   usage: attrib42v.sh <rootA> <rootB> <relative path to slang.uhdm>
set -u
A=$1; B=$2; P=$3   # rootA rootB relpath
D=~/git-repos/UHDM/build/bin/uhdm-dump
norm() { sed -e 's|^.*/\([a-zA-Z0-9_.-]*\.uhdm\)|DB/\1|' -e 's/^[ \t]*//' ; }
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
$D "$A/$P" 2>/dev/null | tail -n +2 | norm > "$T/a.dmp"
$D "$B/$P" 2>/dev/null | tail -n +2 | norm > "$T/b.dmp"
echo "RAW-DIFF lines: $(diff "$T/a.dmp" "$T/b.dmp" | grep -c '^[<>]'; true)"
echo "ORDER-BLIND lines: $(diff <(sort "$T/a.dmp") <(sort "$T/b.dmp") | grep -c '^[<>]'; true)"
diff <(sort "$T/a.dmp") <(sort "$T/b.dmp") | grep '^[<>]' | head -12
