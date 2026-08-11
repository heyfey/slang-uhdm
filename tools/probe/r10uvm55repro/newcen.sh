#!/bin/bash
# r10uvm55repro/newcen.sh — the `new`-CALL census of one row of a verify_golden
# workdir: how many assignments have a NULL Rhs, how many method_func_calls named
# `new`/`super.new` exist, and how many of those are an assignment's Rhs.
#
# LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.
#
#   usage: newcen.sh <workdir> <TestName> <mode> <outdir>
#
# GUARDS: both databases existence-checked (exit 6); asgat's exit 4 propagated;
# the NULL-Rhs count is printed for BOTH sides so "golden also has some" is
# visible rather than assumed.
set -u
WD=${1:?workdir}; NAME=${2:?test}; MODE=${3:?mode}; OUT=${4:?outdir}
P=${ASGAT:-/tmp/r10uvm55_asgat}
[ -x "$P" ] || { echo "FATAL: no asgat at $P"; exit 3; }
D=$(echo "$WD/$MODE/$NAME"-*/ | cut -d' ' -f1)
[ -d "$D" ] || { echo "FATAL: no row dir for $NAME/$MODE under $WD"; exit 3; }
O=$D/slang.uhdm
G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$D/cmds.txt" | head -1)
[ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
[ -f "$G" ] || { echo "NO_OUTPUT: golden absent (${G:-none})"; exit 6; }
[ -f "$O" ] || { echo "NO_OUTPUT: ours absent ($O)"; exit 6; }
mkdir -p "$OUT" || exit 1
"$P" "$G" '' all > "$OUT/g.all"; grc=$?
"$P" "$O" '' all > "$OUT/o.all"; orc=$?
echo "$NAME/$MODE  asgat rc: golden=$grc ours=$orc"
for s in g o; do
  f=$OUT/$s.all
  side=golden; [ "$s" = o ] && side=ours
  tot=$(grep -c '^ASSIGN ' "$f")
  nul=$(grep -c 'rhs=<null>:-' "$f")
  mn=$(grep -c "^MFCALL 'new'" "$f")
  ms=$(grep -c "^MFCALL 'super.new'" "$f")
  rn=$(grep -c "rhs=method_func_call:new" "$f")
  printf "  %-6s assignments=%-6s NULL-Rhs=%-5s Rhs=mfcall(new)=%-5s | mfcall'new'=%-5s mfcall'super.new'=%s\n" \
     "$side" "$tot" "$nul" "$rn" "$mn" "$ms"
done
echo "  OUT=$OUT"
