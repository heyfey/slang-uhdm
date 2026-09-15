#!/usr/bin/env bash
# v11u37 — per-arm PRISTINE vs LAW vs GOLDEN, on the adversarial grid sources.
# usage: armcmp.sh <arm> [<arm> ...]
set -u
G=/tmp/v11u37_grid/out
PRIS=/tmp/v11u37_pris.bin
LAW=/tmp/v11u37_law.bin
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
cd "$G" || exit 3
for n in "$@"; do
  srcs=$(ls ${n}*.svh 2>/dev/null; ls $n.sv 2>/dev/null)
  [ -z "$srcs" ] && { echo "$n: NO SOURCE"; continue; }
  for b in pris law; do
    bin=$PRIS; [ "$b" = law ] && bin=$LAW
    rm -f "s_${b}_$n.uhdm"
    $bin $srcs -o "s_${b}_$n.uhdm" > "s_${b}_$n.log" 2>&1
    echo "  [$n/$b] slang rc=$? db=$([ -f s_${b}_$n.uhdm ] && echo yes || echo NO)"
    [ -f "s_${b}_$n.uhdm" ] || continue
    $DUMP "s_${b}_$n.uhdm" > "s_${b}_$n.dump" 2>&1
  done
  gold="o_$n/slpp_all/surelog.uhdm"
  echo "== $n =="
  for who in gold pris law; do
    f="$n.dump"; [ "$who" = pris ] && f="s_pris_$n.dump"; [ "$who" = law ] && f="s_law_$n.dump"
    [ -f "$f" ] || { echo "  $who: no dump"; continue; }
    printf '  %-5s nets: ' "$who"
    grep -o 'logic_net: (work@[A-Za-z_0-9.]*)' "$f" | sed 's/logic_net: //' | sort | uniq -c | tr '\n' ' '
    echo
  done
  if [ -f "$gold" ] && [ -f "s_pris_$n.uhdm" ]; then
    pl=$($CMP "$gold" "s_pris_$n.uhdm" 2>/dev/null | grep -c '^LHS:'; true)
    ph=$($CMP "$gold" "s_pris_$n.uhdm" 2>&1 >/dev/null | grep -c .; true)
    ll=$($CMP "$gold" "s_law_$n.uhdm" 2>/dev/null | grep -c '^LHS:'; true)
    echo "  cmp LHS lines: pristine=$pl law=$ll   (lower is closer; 0 = equal)"
  fi
done
