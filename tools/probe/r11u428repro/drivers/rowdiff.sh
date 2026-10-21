#!/bin/bash
# usage: rowdiff.sh <workroot> <rel test path> [lines]  -> golden.dump/ours.dump + diff + strictcmp
WR=$1; rel=$2; n=${3:-60}; w=$WR/${rel%.sv}
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
C=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
S=/home/heyfey/git-repos/slang-uhdm/build/uhdm-strictcmp
[ -x "$D" ] && [ -x "$C" ] && [ -x "$S" ] || { echo tools missing; exit 2; }
g=$w/slpp_all/surelog.uhdm
if [ ! -f "$g" ]; then cd0=$(grep -o 'golden cache hit [^)]*' $w/cmds.txt | head -1 | sed 's/golden cache hit //'); g=$cd0/golden.uhdm; fi
echo "golden=$g"
norm() { sed -E "s/\\bid:[0-9]+/id:_/g; s#file:[^ ,]*/#file:#g; s#^[^ ]*/([^/ ]*: Restored)#\1#" ; }
$D $g 2>/dev/null | norm > $w/golden.dump
$D $w/slang.uhdm 2>/dev/null | norm > $w/ours.dump
echo "== golden $(wc -l < $w/golden.dump) ours $(wc -l < $w/ours.dump)"
$C $g $w/slang.uhdm 2>&1 | head -20
$S --max 8 $g $w/slang.uhdm 2>&1 | head -30
diff -u $w/golden.dump $w/ours.dump | grep -vE '^(---|\+\+\+)' | grep -E '^[-+@]' | head -n $n
