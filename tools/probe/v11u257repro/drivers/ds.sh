#!/bin/bash
# v11u257 ds.sh <tag> <binary> <workroot> <case dir>...: the downstream harness on each case (r11u257's dscases.py,
# fail-closed on $FENCED) with the given binary in the slang lane.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
tag=$1; bin=$2; wr=$3; shift 3; [ -x "$bin" ] || { echo "ds.sh: binary not executable" >&2; exit 2; }
SLANG_UHDM=$bin python3 $R257_D/dscases.py $tag $wr "$@"
