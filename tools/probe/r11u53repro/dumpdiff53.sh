#!/bin/bash
# r11u53 dumpdiff53.sh — order-blind whole-dump residue per corpus row.
# usage: dumpdiff.sh <rowdir> <outprefix>
set -u
D=${1:?rowdir}; O=${2:?outprefix}
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$D/cmds.txt" | head -1)/golden.uhdm
S=$D/slang.uhdm
[ -f "$G" ] || { echo "FATAL no golden $G"; exit 3; }
[ -f "$S" ] || { echo "FATAL no ours $S"; exit 3; }
$DUMP "$G" 2>/dev/null | sed -e "s#$(dirname $G)/##g" -e 's#/home/heyfey/[^ ,)]*/##g' > $O.g.txt
$DUMP "$S" 2>/dev/null | sed -e "s#$D/##g" -e 's#/home/heyfey/[^ ,)]*/##g' > $O.o.txt
sort $O.g.txt > $O.gs.txt; sort $O.o.txt > $O.os.txt
diff $O.gs.txt $O.os.txt > $O.diff.txt; true
echo "$(basename $D) golden=$(wc -l < $O.g.txt) ours=$(wc -l < $O.o.txt) orderblind_diff=$(wc -l < $O.diff.txt) gonly=$(grep -c '^<' $O.diff.txt; true) oonly=$(grep -c '^>' $O.diff.txt; true)"
