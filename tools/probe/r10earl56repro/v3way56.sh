#!/usr/bin/env bash
# r10earl56 VERIFIER 3-way arm driver.  LHS is ALWAYS golden.
# Runs Surelog ONCE and BOTH binaries in the SAME directory so every dump path
# is identical (no normalisation needed and no path-vs-defect confusion).
#   usage: v3way.sh <abs .sv> <workdir> [--plain]
set -u
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
PAT=${PAT:?patched bin}
PRIS=${PRIS:?pristine bin}
SRC=${1:?src}; D=${2:?wd}; MODE=${3:-elab}
for t in "$SURELOG" "$DUMP" "$CMP" "$PAT" "$PRIS"; do
  [ -x "$t" ] || { echo "FATAL: no such tool $t"; exit 9; }
done
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
B=$(basename "$SRC")
cd "$D" || exit 9
if [ "$MODE" = plain ]; then SLF=""; OF=""; else SLF="-elabuhdm"; OF="--elabuhdm"; fi
"$SURELOG" -parse $SLF -nocache -mt 0 -mp 0 "$B" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo SURELOG_FAIL; tail -12 surelog.log; exit 5; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed '1d' > g.dump
[ -s g.dump ] || { echo NO_GOLDEN_DUMP; exit 7; }
"$PRIS" $OF "$B" -o pris.uhdm >pris.log 2>&1
"$PAT"  $OF "$B" -o pat.uhdm  >pat.log  2>&1
[ -f pris.uhdm ] || { echo NO_PRIS_OUTPUT; tail -8 pris.log; exit 6; }
[ -f pat.uhdm ]  || { echo NO_PAT_OUTPUT;  tail -8 pat.log;  exit 6; }
"$DUMP" pris.uhdm 2>/dev/null | sed '1d' > p.dump
"$DUMP" pat.uhdm  2>/dev/null | sed '1d' > q.dump
"$CMP" slpp_all/surelog.uhdm pris.uhdm >cmp_pris.log 2>&1 && echo PRIS_PASS_CMP || echo PRIS_CMP_FAIL
"$CMP" slpp_all/surelog.uhdm pat.uhdm  >cmp_pat.log  2>&1 && echo PAT_PASS_CMP  || echo PAT_CMP_FAIL
echo "cmp pris heads=$(grep -c '^LHS:' cmp_pris.log) lines=$(wc -l < cmp_pris.log)"
echo "cmp pat  heads=$(grep -c '^LHS:' cmp_pat.log)  lines=$(wc -l < cmp_pat.log)"
if diff -q p.dump q.dump >/dev/null; then echo "PRIS_PAT_DUMP_IDENTICAL"
else echo "PRIS_PAT_DUMP_DIFF changed=$(diff p.dump q.dump | grep -cE '^[<>]')"; fi
echo "WD=$D"
