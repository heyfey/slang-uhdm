#!/bin/bash
# usage: r11u404_pair.sh <workroot> <rel test path> [n]  -> strictcmp + dump diff
source /tmp/r11u404_env.sh
W=$1; rel=$2; n=${3:-60}; w=$W/${rel%.sv}
G=$(grep -o 'golden cache hit [^)]*' $w/cmds.txt | awk '{print $4}')/golden.uhdm
[ -f $w/slpp_all/surelog.uhdm ] && G=$w/slpp_all/surelog.uhdm
SC=${SC:-/home/heyfey/git-repos/slang-uhdm/build/uhdm-strictcmp}
echo "golden=$G"
timeout 300 $SC --max 5 $G $w/slang.uhdm 2>&1 | head -40
norm() { sed -E "s/\\bid:[0-9]+/id:_/g; s#file:[^ ,]*/#file:#g; s#^[^ ]*\.uhdm: Restored#X Restored#" ; }
[ -x "$UHDM_DUMP" ] || exit 1
$UHDM_DUMP $G 2>/dev/null | norm > $w/golden.dump
$UHDM_DUMP $w/slang.uhdm 2>/dev/null | norm > $w/ours.dump
echo "== golden $(wc -l < $w/golden.dump) ours $(wc -l < $w/ours.dump)"
diff -u $w/golden.dump $w/ours.dump | grep -vE '^(---|\+\+\+)' | head -n $n
