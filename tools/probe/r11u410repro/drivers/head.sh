#!/bin/bash
# head.sh <workroot> <relpath-without-.sv> : strictcmp head
d=$1/$2; g=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[^) ]*' $d/cmds.txt | head -1)/golden.uhdm
[ -f $d/slpp_all/surelog.uhdm ] && g=$d/slpp_all/surelog.uhdm
/tmp/wt_r11u410/build/uhdm-strictcmp --max 3 $g $d/slang.uhdm 2>&1 | grep -E '^(lhsPath|rhsPath)|EQUAL|differ' | cut -c1-300
