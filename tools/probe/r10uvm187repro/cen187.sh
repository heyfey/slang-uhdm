#!/usr/bin/env bash
# r10uvm187 — THE PER-ROW PARAMETER-TYPESPEC CENSUS, golden vs pristine vs
# patched, for a NAMED SUBSET of rows in two verify_golden workdirs.
# MEASUREMENT ONLY; the official uhdm-cmp is the judge.
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   usage: CEN=<ct187cen> cen187.sh <pristine-workdir> <patched-workdir> <name>...
#
# For each (name, mode) it prints
#     CELLS   how many package/class/module-listing `parameter` cells the two
#             censuses share
#     P-MATCH how many the PRISTINE binary already got right
#     Q-MATCH how many the PATCHED binary gets right
#     FACE    how many cells carry THIS law's golden shape (a per-declaration
#             NAMED CLONE of a scalar typedef: bare VpiName, Typedef_alias,
#             rg=0, vpiParent == the parameter) and disagree
# GUARDS: a missing golden or slang.uhdm prints SKIP-NOFILE and is COUNTED --
# a driver that reaches nothing must never read as perfection.
set -u
P=$(readlink -f "${1:?pristine workdir}"); shift
Q=$(readlink -f "${1:?patched workdir}"); shift
CEN=${CEN:?path to ct187cen}
[ -x "$CEN" ] || { echo "FATAL: no ct187cen at $CEN"; exit 3; }
key() { awk -F'\t' '{print $1"|"$2"|"$3"|"$4"|"$5"\t"$6}' | sort; }
face() {  # count join rows whose GOLDEN side carries the law's shape and differs
  awk -F'\t' '
    $2 != $3 &&
    $2 ~ /^(int_typespec|byte_typespec|bit_typespec)\(/ &&
    $2 !~ /^[a-z_]*typespec\(\)/ &&
    substr($2, index($2,"(")+1, index($2,")")-index($2,"(")-1) !~ /::/ &&
    $2 ~ /\[alias->/ && $2 ~ /rg=0/ && $2 ~ /apar=parameter/ {n++}
    END {print n+0}'
}
printf "%-16s %-9s %7s %7s %7s %6s %6s\n" TEST MODE CELLS P-MATCH Q-MATCH FACE-P FACE-Q
miss=0; seen=0
for n in "$@"; do
  for mode in default testflags; do
    for d in "$P/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      b=$(basename "$d"); e="$Q/$mode/$b"
      G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" 2>/dev/null | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$d/slang.uhdm" ] || [ ! -f "$e/slang.uhdm" ]; then
        printf "%-16s %-9s %7s %7s %7s %6s %6s\n" "$n" "$mode" - - - - - ; miss=$((miss+1)); continue
      fi
      "$CEN" "$G"            2>/dev/null | key > /tmp/.c187g.$$
      "$CEN" "$d/slang.uhdm" 2>/dev/null | key > /tmp/.c187p.$$
      "$CEN" "$e/slang.uhdm" 2>/dev/null | key > /tmp/.c187q.$$
      jp=$(join -t$'\t' -j1 /tmp/.c187g.$$ /tmp/.c187p.$$)
      jq=$(join -t$'\t' -j1 /tmp/.c187g.$$ /tmp/.c187q.$$)
      cells=$(printf '%s\n' "$jp" | grep -c . ; true)
      pm=$(printf '%s\n' "$jp" | awk -F'\t' '$2==$3{n++} END{print n+0}')
      qm=$(printf '%s\n' "$jq" | awk -F'\t' '$2==$3{n++} END{print n+0}')
      fp=$(printf '%s\n' "$jp" | face)
      fq=$(printf '%s\n' "$jq" | face)
      printf "%-16s %-9s %7s %7s %7s %6s %6s\n" "$n" "$mode" "$cells" "$pm" "$qm" "$fp" "$fq"
      seen=$((seen+1))
      rm -f /tmp/.c187g.$$ /tmp/.c187p.$$ /tmp/.c187q.$$
    done
  done
done
echo "-- measured=$seen SKIP-NOFILE=$miss"
