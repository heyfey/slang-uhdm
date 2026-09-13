#!/usr/bin/env bash
# shapecmp.sh <pristine-workdir> <patched-workdir> <mode> <names...>
# THE SHAPE LISTER beside the census (the r11v7 lesson: a row-keyed value
# scorer reads CLEAN across a real break; a break shows in the SHAPE of the
# operand tree).  Per row, counts the param_assign keys whose Rhs OBJECT-KIND
# chain differs from golden's, on both binaries.  The count must never GROW.
set -u
P=$1; Q=$2; M=$3; shift 3
UD=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d /tmp/r11u9_shapecmp.XXXXXX)
trap 'rm -rf "$T"' EXIT
grew=0
for n in "$@"; do
  pd=$(ls -d "$P/$M/$n"-* 2>/dev/null | head -1)
  qd=$(ls -d "$Q/$M/$n"-* 2>/dev/null | head -1)
  [ -z "$pd" ] || [ -z "$qd" ] && { echo "$n MISSING"; continue; }
  gold=$(grep -o 'golden cache hit [^)]*' "$pd/cmds.txt" | sed 's/golden cache hit //')
  g=$(find "$gold" \( -name golden.uhdm -o -name surelog.uhdm \) 2>/dev/null | head -1)
  [ -z "$g" ] && { echo "$n NO-GOLDEN"; continue; }
  "$UD" "$g" > "$T/g" 2>/dev/null
  "$UD" "$pd/slang.uhdm" > "$T/p" 2>/dev/null
  "$UD" "$qd/slang.uhdm" > "$T/q" 2>/dev/null
  sp=$(python3 "$HERE/shapes.py" "$T/g" "$T/p" | tail -1 | awk '{print $NF}')
  sq=$(python3 "$HERE/shapes.py" "$T/g" "$T/q" | tail -1 | awk '{print $NF}')
  v=same; [ "$sq" -lt "$sp" ] && v=IMPROVED; [ "$sq" -gt "$sp" ] && { v=GREW; grew=$((grew+1)); }
  echo "$n $M shape_diff pristine=$sp patched=$sq $v"
done
echo "SHAPE-GREW ROWS: $grew"
