#!/bin/bash
# Surelog-suite verification. Runs BOTH tools in Surelog's DEFAULT (pre-elab) mode
# -- the mode our exporter targets -- so the comparison is apples-to-apples.
# The suite's own .sl args mostly add -elabuhdm (post-elab), which we do not implement.
ROOT=$(cd "$(dirname "$(realpath "$0")")/.." && pwd)
SURELOG_ROOT=${SURELOG_ROOT:-$ROOT/third_party/Surelog}
UHDM_BIN=$SURELOG_ROOT/build/third_party/UHDM/bin
UHDM_CMP=${UHDM_CMP:-$UHDM_BIN/uhdm-cmp}
SURELOG=${SURELOG:-$SURELOG_ROOT/build/bin/surelog}
SLANG=${SLANG_UHDM:-$ROOT/build/slang-uhdm}
d="$1"; name=$(basename "$d")
srcs=$(ls "$d"/*.v "$d"/*.sv 2>/dev/null)
n=$(echo "$srcs" | grep -c .)
[ "$n" -eq 1 ] || { echo "$name,SKIP_MULTIFILE,n=$n"; exit 0; }
src=$(realpath "$srcs")
w=$(mktemp -d /tmp/vsrlg.XXXXXX); cd "$w" || exit 9
timeout 120 "$SURELOG" -parse -nobuiltin -nocache "$src" >sl.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo "$name,SURELOG_FAIL,-"; rm -rf "$w"; exit 0; }
timeout 120 "$SLANG" "$src" -o slang.uhdm >sg.log 2>&1; se=$?
[ -f slang.uhdm ] || { echo "$name,SLANG_REJECT,exit=$se"; rm -rf "$w"; exit 0; }
timeout 120 "$UHDM_CMP" slpp_all/surelog.uhdm slang.uhdm >cmp.log 2>&1; ce=$?
if [ $ce -eq 0 ]; then echo "$name,CMP_EQUAL,0"; else echo "$name,CMP_NOTEQUAL,exit=$ce"; fi
rm -rf "$w"
