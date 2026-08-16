#!/usr/bin/env bash
# vsd10 VERIFIER arm: golden + BOTH binaries in ONE scratch dir, so every
# absolute path uhdm-dump prints (Surelog's synthesized builtin.sv) is identical
# across all three reads and pris-vs-pat dump diffs are meaningful.
set -u
SRC=${1:?arm source}
PAT=${PAT:?set PAT to the PATCHED binary}
PRI=${PRI:?set PRI to the PRISTINE binary}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
B=$(basename "$SRC"); B=${B%.*}
D=${2:-/tmp/vsd10_arm_$B}
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
LEAF=$(basename "$SRC")
cd "$D" || exit 9
"$SURELOG" -parse -nocache "$LEAF" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo "SURELOG_FAIL $B"; tail -8 surelog.log; exit 5; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed 1d > g.dump
kindtab() { grep -oE '\\_[a-z_]*_var: \([^)]*\), line:[0-9]+:[0-9]+' "$1" |
    sed -E 's/^\\_//; s/: \(/ /; s/\), line:/ @/' | LC_ALL=C sort -u ; }
kindtab g.dump > g.kinds
echo "== $B  golden_var_rows=$(wc -l < g.kinds)"
for tag in pris pat; do
  bin=$PRI; [ $tag = pat ] && bin=$PAT
  "$bin" "$LEAF" -o $tag.uhdm > $tag.log 2>&1
  if [ ! -f $tag.uhdm ]; then echo "  [$tag] NO_OUTPUT"; tail -4 $tag.log; continue; fi
  "$DUMP" $tag.uhdm 2>/dev/null | sed 1d > $tag.dump
  kindtab $tag.dump > $tag.kinds
  res=$("$CMP" slpp_all/surelog.uhdm $tag.uhdm >$tag.cmp 2>&1 && echo PASS_CMP || echo CMP_FAIL)
  dd=$(diff -u g.dump $tag.dump | grep -E '^[-+]' | grep -vcE '^(---|\+\+\+) '; true)
  ks=$(comm -3 g.kinds $tag.kinds | wc -l)
  echo "  [$tag] $res heads=$(grep -c '^LHS:' $tag.cmp; true) dumpcontent=$dd KIND_differing_sides=$ks"
done
if [ -f pris.kinds ] && [ -f pat.kinds ]; then
  echo "  -- golden vs pris vs pat, per variable (G=golden P=pris Q=patched):"
  LC_ALL=C join -j 2 -o 0,1.1,2.1 -a1 -a2 -e MISSING \
    <(awk '{print $1, $2}' g.kinds | LC_ALL=C sort -k2) \
    <(awk '{print $1, $2}' pris.kinds | LC_ALL=C sort -k2) 2>/dev/null > /dev/null
  LC_ALL=C sort -u -k2 g.kinds | awk '{print $2"\tG="$1}' > .g
  LC_ALL=C sort -u -k2 pris.kinds | awk '{print $2"\tP="$1}' > .p
  LC_ALL=C sort -u -k2 pat.kinds | awk '{print $2"\tQ="$1}' > .q
  LC_ALL=C join -t $'\t' -a1 -a2 -e '-' -o 0,1.2,2.2 .g .p > .gp
  LC_ALL=C join -t $'\t' -a1 -a2 -e '-' -o 0,1.2,1.3,2.2 .gp .q |
    awk -F'\t' '{ok=($2==$3 && $3==$4)?"    ":( ($2==$4 && $2!=$3)?" FIX":( ($2==$3 && $2!=$4)?" BREAK":" DIFF"));printf "  %s %-58s %-18s %-18s %s\n",ok,$1,$2,$3,$4}'
fi
if [ -f pris.dump ] && [ -f pat.dump ]; then
  cmp -s pris.dump pat.dump && echo "  DUMPS pris==pat BYTE-IDENTICAL" \
    || echo "  DUMPS pris->pat moved $(diff -u pris.dump pat.dump | grep -E '^[-+]' | grep -vcE '^(---|\+\+\+) '; true) content lines"
fi
echo "  WD=$D"
