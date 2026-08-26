#!/usr/bin/env bash
# r10uvm153 — THE BINDING CENSUS over a verify_golden workdir, by NAME.
# MEASUREMENT ONLY; the official uhdm-cmp is the judge.  LHS is always golden.
# Both sides are existence-checked (uhdm-cmp exits 0 on a missing input, and a
# census that reaches nothing must never read as perfection): a missing side
# prints SKIP-NOFILE and is COUNTED.  The golden path is read out of the
# workdir's OWN cmds.txt.
#   usage: CT=<ct153bind> scan153.sh <workdir> <outdir> <name> [<name> ...]
set -u
WD=${1:?workdir}; OUT=${2:?outdir}; shift 2
CT=${CT:?set CT to the ct153bind binary}
mkdir -p "$OUT"
printf "%-24s %-9s %6s %6s %6s %6s %6s %6s %s\n" TEST MODE SAME GBOUND OBOUND DIFF ONLYG ONLYO NOTE
miss=0; done_=0
for n in "$@"; do
  for mode in default testflags; do
    for d in "$WD/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      O=$d/slang.uhdm; C=$d/cmds.txt; G=""
      [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
        printf "%-24s %-9s %6s %6s %6s %6s %6s %6s %s\n" "$n" "$mode" - - - - - - "SKIP-NOFILE"
        miss=$((miss+1)); continue
      fi
      F=$OUT/$n.$mode.bind.txt
      "$CT" "$G" "$O" > "$F" 2>&1; rc=$?
      L=$(tail -1 "$F")
      printf "%-24s %-9s %6s %6s %6s %6s %6s %6s %s\n" "$n" "$mode" \
        "$(sed 's/.*SAME=\([0-9]*\).*/\1/' <<<"$L")" \
        "$(sed 's/.*GOLD-BOUND=\([0-9]*\).*/\1/' <<<"$L")" \
        "$(sed 's/.*OURS-BOUND=\([0-9]*\).*/\1/' <<<"$L")" \
        "$(sed 's/.*DIFF=\([0-9]*\).*/\1/' <<<"$L")" \
        "$(sed 's/.*ONLY-GOLD=\([0-9]*\).*/\1/' <<<"$L")" \
        "$(sed 's/.*ONLY-OURS=\([0-9]*\).*/\1/' <<<"$L")" "rc=$rc"
      done_=$((done_+1))
    done
  done
done
echo "-- censused=$done_  SKIP-NOFILE=$miss"
