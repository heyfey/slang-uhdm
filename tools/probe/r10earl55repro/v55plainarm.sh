#!/usr/bin/env bash
# v55 verifier — the PLAIN-VIEW arm with a PLAIN GOLDEN and a full compare.
# armplain55.sh only checks that both sides produce a database; the boundary
# sweep shows every width-1 arm CHANGING in the plain view too, so the plain
# view needs its OWN golden-vs-ours measurement or the fence is asserted, not
# measured.  Surelog: -parse, NO -elabuhdm.  Ours: NO --elabuhdm.
set -u
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
SRC=${1:?src}; D=${2:?wd}
: "${SLANG_UHDM:?}"
rm -rf "$D"; mkdir -p "$D"; cp "$SRC" "$D/" || exit 9
B=$(basename "$SRC"); cd "$D" || exit 9
"$SURELOG" -parse -nocache -mt 0 -mp 0 "$B" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo SURELOG_FAIL; exit 5; }
"$SLANG_UHDM" "$B" -o slang.uhdm >slang.log 2>&1
[ -f slang.uhdm ] || { echo NO_OUTPUT; tail -3 slang.log; exit 6; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed '1d' > g.dump
"$DUMP" slang.uhdm 2>/dev/null | sed '1d' > o.dump
"$CMP" slpp_all/surelog.uhdm slang.uhdm >cmp.log 2>&1 && echo PASS_CMP || echo CMP_FAIL
echo "cmp heads=$(grep -c '^LHS:' cmp.log) lines=$(wc -l < cmp.log)"
diff -u g.dump o.dump > d.diff && echo DUMP_MATCH || echo "DUMP_DIFF content=$(grep -cE '^[-+]' d.diff)"
echo "WD=$D"
