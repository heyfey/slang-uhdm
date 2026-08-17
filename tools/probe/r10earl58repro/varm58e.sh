#!/usr/bin/env bash
# v58 VERIFIER arm driver — ELABORATED both sides (-elabuhdm / --elabuhdm).
set -u
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
SRC=${1:?arm source}
D=${2:?workdir}
: "${SLANG_UHDM:?set SLANG_UHDM}"
[ -x "$SLANG_UHDM" ] || { echo "FATAL no binary $SLANG_UHDM"; exit 9; }
for t in "$SURELOG" "$DUMP" "$CMP"; do [ -x "$t" ] || { echo "FATAL no tool $t"; exit 9; }; done
echo "BINARY $SLANG_UHDM md5=$(md5sum "$SLANG_UHDM" | cut -d' ' -f1)"
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
B=$(basename "$SRC")
cd "$D" || exit 9
"$SURELOG" -parse -elabuhdm -nocache -mt 0 -mp 0 "$B" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo SURELOG_FAIL; tail -8 surelog.log; exit 5; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed '1d' > g.dump
[ -s g.dump ] || { echo NO_GOLDEN_DUMP; exit 7; }
"$SLANG_UHDM" --elabuhdm "$B" -o slang.uhdm >slang.log 2>&1
[ -f slang.uhdm ] || { echo NO_OUTPUT; tail -8 slang.log; exit 6; }
"$DUMP" slang.uhdm 2>/dev/null | sed '1d' > o.dump
[ -s o.dump ] || { echo NO_OURS_DUMP; exit 7; }
"$CMP" slpp_all/surelog.uhdm slang.uhdm >cmp.log 2>&1 && echo PASS_CMP || echo CMP_FAIL
echo "cmp heads=$(grep -c '^LHS:' cmp.log) lines=$(wc -l < cmp.log)"
if diff -u g.dump o.dump > d.diff; then echo DUMP_MATCH; else
  echo "DUMP_DIFF content=$(grep -E '^[-+]' d.diff | grep -vcE '^(---|\+\+\+) ') hunks=$(grep -c '^@@' d.diff)"; fi
echo "WD=$PWD"
