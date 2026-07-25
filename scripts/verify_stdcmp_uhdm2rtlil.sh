#!/bin/bash
# Independent verification: run surelog + slang-uhdm, then the STANDARD uhdm-cmp directly.
UHDM_CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
SLANG=$HOME/git-repos/slang-uhdm/build/slang-uhdm
d="$1"; name=$(basename "$d"); dut="$d/dut.sv"
[ -f "$dut" ] || exit 0
w=$(mktemp -d /tmp/vcmp.XXXXXX); cd "$w" || exit 9
if ! "$SURELOG" -parse -nobuiltin -nocache "$dut" >sl.log 2>&1; then echo "$name,SURELOG_FAIL,-"; rm -rf "$w"; exit 0; fi
[ -f slpp_all/surelog.uhdm ] || { echo "$name,SURELOG_NO_UHDM,-"; rm -rf "$w"; exit 0; }
"$SLANG" "$dut" -o slang.uhdm >sg.log 2>&1; se=$?
[ -f slang.uhdm ] || { echo "$name,SLANG_REJECT,exit=$se"; rm -rf "$w"; exit 0; }
"$UHDM_CMP" slpp_all/surelog.uhdm slang.uhdm >cmp.log 2>&1; ce=$?
if [ $ce -eq 0 ]; then echo "$name,CMP_EQUAL,0"; else echo "$name,CMP_NOTEQUAL,exit=$ce $(head -c 200 cmp.log|tr '\n' ' ')"; fi
rm -rf "$w"
