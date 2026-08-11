#!/bin/bash
# r10uvm55repro/ctscen.sh — the class_typespec PARAMETER census, BOTH SIDES of one
# row of a verify_golden workdir, using ctsfield.
#
# LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.
#
#   usage: ctscen.sh <workdir> <TestName> <mode> <outdir> [nameFilter]
#
# GUARDS:
#   * both databases are existence-checked BEFORE the probe runs; a missing one
#     is exit 6 (uhdm-cmp exits 0 on a missing input and so would a naive probe).
#   * ctsfield's own exit 4 (`UNMEASURED: 0 class_typespec matched`) is
#     PROPAGATED, not swallowed — a filter that reaches nothing must not read as
#     "no difference".
#   * the census counts a NULL vector and an EMPTY vector separately, because
#     SafeCompare treats null-vs-empty as EQUAL and non-empty-vs-null as a FAIL.
set -u
WD=${1:?workdir}
NAME=${2:?test}
MODE=${3:?mode}
OUT=${4:?outdir}
FILT=${5:-}
P=${CTSFIELD:-/tmp/r10uvm55_ctsfield}
[ -x "$P" ] || { echo "FATAL: no ctsfield at $P (run pbuild.sh ctsfield)"; exit 3; }
D=$(echo "$WD/$MODE/$NAME"-*/ | cut -d' ' -f1)
[ -d "$D" ] || { echo "FATAL: no row dir for $NAME/$MODE under $WD"; exit 3; }
O=$D/slang.uhdm
G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$D/cmds.txt" | head -1)
[ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
[ -f "$G" ] || { echo "NO_OUTPUT: golden absent (${G:-none})"; exit 6; }
[ -f "$O" ] || { echo "NO_OUTPUT: ours absent ($O)"; exit 6; }
mkdir -p "$OUT" || exit 1
"$P" "$G" "$FILT" > "$OUT/g.cts"; grc=$?
"$P" "$O" "$FILT" > "$OUT/o.cts"; orc=$?
echo "$NAME/$MODE  ctsfield rc: golden=$grc ours=$orc  filter='${FILT}'"
[ "$grc" = 4 ] && { echo "UNMEASURED on golden"; exit 4; }
[ "$orc" = 4 ] && { echo "UNMEASURED on ours"; exit 4; }
for s in g o; do
  f=$OUT/$s.cts
  tot=$(grep -c '^CTS ' "$f")
  pnull=$(grep '^  CMP' "$f" | grep -c 'parameters=null')
  pzero=$(grep '^  CMP' "$f" | grep -c 'parameters=0 ')
  pge1=$(grep '^  CMP' "$f" | grep -cE 'parameters=[1-9]')
  anull=$(grep '^  CMP' "$f" | grep -c 'paramassigns=null')
  age1=$(grep '^  CMP' "$f" | grep -cE 'paramassigns=[1-9]')
  side=golden; [ "$s" = o ] && side=ours
  printf "  %-6s class_typespec=%-6s parameters: null=%-6s empty=%-4s >=1=%-6s | paramassigns: null=%-6s >=1=%s\n" \
     "$side" "$tot" "$pnull" "$pzero" "$pge1" "$anull" "$age1"
done
echo "  OUT=$OUT"
