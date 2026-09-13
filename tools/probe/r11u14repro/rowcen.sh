#!/usr/bin/env bash
# rowcen.sh <pris-workdir-root> <pat-workdir-root> <mode> <name...>
# Per-param_assign directional census against the row's OWN golden, unclipped.
set -u
P=$1; Q=$2; M=$3; shift 3
UD=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
T=${T:-$(mktemp -d /tmp/r11vu13_rowcen.XXXXXX)}; mkdir -p "$T"
for n in "$@"; do
  pd=$(ls -d "$P/$M/$n"-* 2>/dev/null | head -1)
  qd=$(ls -d "$Q/$M/$n"-* 2>/dev/null | head -1)
  [ -z "$pd" ] || [ -z "$qd" ] && { echo "$n MISSING"; continue; }
  gold=$(grep -o 'golden cache hit [^)]*' "$pd/cmds.txt" | sed 's/golden cache hit //')
  g=$(find "$gold" \( -name golden.uhdm -o -name surelog.uhdm \) 2>/dev/null | head -1)
  [ -z "$g" ] && { echo "$n NO-GOLDEN"; continue; }
  "$UD" "$g" > "$T/g.dump" 2>/dev/null
  "$UD" "$pd/slang.uhdm" > "$T/p.dump" 2>/dev/null
  "$UD" "$qd/slang.uhdm" > "$T/q.dump" 2>/dev/null
  echo "#### $n [$M]"
  python3 "$(dirname "$0")"/pacmp.py "$T/g.dump" "$T/p.dump" "$T/q.dump"
done
