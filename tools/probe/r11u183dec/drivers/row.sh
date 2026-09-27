#!/bin/bash
# r11u183: strict records of one corpus row-mode from a sweep dir (read-only), for decoding.
# usage: row.sh <sweepdir> <corpus> <mode> <test> [max]   -> /tmp/r11u183_rows/<corpus>/<mode>/<test>/{strict.txt,a.rec,b.rec}
# Refuses the four fenced names (the FENCED= line of r11u107repro/canaudit.sh), by word boundary.
set -u; S=$1 c=$2 m=$3 t=$4 mx=${5:-50}
HERE=$(cd "$(dirname "$0")" && pwd)
FENCED="$(grep -m1 '^FENCED=' "$HERE/../../r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "row.sh: fence unreadable" >&2; exit 3; }
for f in $FENCED; do [ "$t" = "$f" ] && { echo "row.sh: fenced row refused" >&2; exit 3; }; done
d=$(ls -d "$S/$c/$m/$t"-* "$S/$m/$t"-* 2>/dev/null | head -1); [ -n "$d" ] || { echo "no dir"; exit 1; }
g=$(grep -o 'golden cache hit [^)]*' "$d/cmds.txt" | cut -d' ' -f4)/golden.uhdm
[ -f "$g" ] || g=$(grep -o 'golden[^ ]*uhdm' "$d/cmds.txt" | head -1)
O=/tmp/r11u183_rows/$c/$m/$t; mkdir -p "$O"
timeout 1800 ${SCMP:-/tmp/r11u183_bin/uhdm-strictcmp} --max $mx --dump-a "$O/a.rec" --dump-b "$O/b.rec" "$g" "$d/slang.uhdm" > "$O/strict.txt" 2>&1
echo "rc=$? $(grep -m1 -E '^(STRICT_|NOT_EQUAL)' $O/strict.txt) golden=$g"
