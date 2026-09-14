#!/usr/bin/env bash
# cen20.py on NAMED SWEEP ROWS, against each row's OWN golden: the KEYED
# directional census (TP bound cells + TF listings), pristine vs patched.
#   usage: PRIS=<workdir> PAT=<workdir> rowcen20.sh <mode> <name>...
set -u
H=$(cd "$(dirname "$0")" && pwd)
P=${PRIS:?pristine workdir root}
Q=${PAT:?patched workdir root}
M=${1:?mode}; shift
UD=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
T=$(mktemp -d /tmp/r11u20_rowcen.XXXXXX)
trap 'rm -rf "$T"' EXIT
for n in "$@"; do
  pd=$(ls -d "$P/$M/$n"-* 2>/dev/null | head -1)
  qd=$(ls -d "$Q/$M/$n"-* 2>/dev/null | head -1)
  { [ -z "$pd" ] || [ -z "$qd" ]; } && { echo "$n MISSING-ROW"; continue; }
  gold=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$pd/cmds.txt" | head -1)
  g=$(find "$gold" \( -name golden.uhdm -o -name surelog.uhdm \) 2>/dev/null | head -1)
  [ -z "$g" ] && { echo "$n NO-GOLDEN"; continue; }
  "$UD" "$g"             > "$T/g" 2>/dev/null
  "$UD" "$pd/slang.uhdm" > "$T/p" 2>/dev/null
  "$UD" "$qd/slang.uhdm" > "$T/q" 2>/dev/null
  echo "===== $n [$M]"
  python3 "$H/cen20.py" "$T/g" "$T/p" "$T/q"
done
