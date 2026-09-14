#!/usr/bin/env bash
# rowcen18.sh — the r11u18 KEYED directional census (cen18.py) on NAMED SWEEP
# ROWS, against each row's OWN golden.  usage:
#   PRIS=<workdir root> PAT=<workdir root> rowcen18.sh <mode> <name>...
set -u
P=${PRIS:?pristine workdir root}; Q=${PAT:?patched workdir root}
M=${1:?mode}; shift
UD=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
T=$(mktemp -d /tmp/r11u18_rowcen.XXXXXX)
for n in "$@"; do
  pd=$(ls -d "$P/$M/$n"-* 2>/dev/null | head -1)
  qd=$(ls -d "$Q/$M/$n"-* 2>/dev/null | head -1)
  [ -z "$pd" ] || [ -z "$qd" ] && { echo "$n MISSING-ROW"; continue; }
  gold=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$pd/cmds.txt" | head -1)
  g=$(find "$gold" \( -name golden.uhdm -o -name surelog.uhdm \) 2>/dev/null | head -1)
  [ -z "$g" ] && { echo "$n NO-GOLDEN"; continue; }
  "$UD" "$g" > "$T/g" 2>/dev/null
  "$UD" "$pd/slang.uhdm" > "$T/p" 2>/dev/null
  "$UD" "$qd/slang.uhdm" > "$T/q" 2>/dev/null
  python3 "$(dirname "$0")"/cen18.py "$T/g" "$T/p" "$T/q" "$n[$M]"
done
rm -rf "$T"
