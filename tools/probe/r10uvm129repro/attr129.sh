#!/usr/bin/env bash
# r10uvm129 — MOVER ATTRIBUTION.  For one row-mode, uhdm-dump both the pristine
# and the patched database, normalise the WORKDIR PATH out of both, and diff
# them BOTH in file order and ORDER-BLIND (sorted) — Scoreboard/default is a
# ~50/50 coin per invocation, so only the order-blind diff is attributable.
# MEASUREMENT ONLY — the official uhdm-cmp is the judge.
#   usage: PRISWD=.. PATWD=.. attr129.sh <mode> <test> <outdir>
set -u
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
PRISWD=${PRISWD:?}; PATWD=${PATWD:?}
m=$1; t=$2; OUT=$(readlink -f "$3"); mkdir -p "$OUT"
dp=$(ls -d "$PRISWD/$m/$t"-* 2>/dev/null | head -1)
dq=$(ls -d "$PATWD/$m/$t"-*  2>/dev/null | head -1)
[ -n "$dp" ] && [ -n "$dq" ] || { echo "$m/$t NODIR"; exit 3; }
for s in p q; do
  [ $s = p ] && d=$dp || d=$dq
  "$DUMP" "$d/slang.uhdm" 2>/dev/null </dev/null \
    | sed -e "s#$PRISWD##g" -e "s#$PATWD##g" > "$OUT/$t.$m.$s.dump"
  sort "$OUT/$t.$m.$s.dump" > "$OUT/$t.$m.$s.sorted"
done
inorder=$(diff "$OUT/$t.$m.p.dump" "$OUT/$t.$m.q.dump" | grep -cE '^[<>]'; true)
blind=$(diff "$OUT/$t.$m.p.sorted" "$OUT/$t.$m.q.sorted" | grep -cE '^[<>]'; true)
echo "$m/$t  in-order=$inorder  ORDER-BLIND=$blind"
diff "$OUT/$t.$m.p.sorted" "$OUT/$t.$m.q.sorted" | grep -E '^[<>]' | sed 's/^/    /'
