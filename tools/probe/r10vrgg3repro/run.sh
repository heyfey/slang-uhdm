#!/usr/bin/env bash
# r10vrgg3 adversarial runner — OFFICIAL uhdm-cmp as the judge (golden = LHS).
# For each cell: golden(Surelog), BASE, PAT.  Reports the status PAIR so a
# pristine-right -> patched-wrong is impossible to miss.
set -u
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
BASE=${BASE:?}; PAT=${PAT:?}
root=$(cd "$(dirname "$0")" && pwd)
printf "%-32s %-14s %-14s %s\n" CELL BASE PAT NOTE
for d in "$@"; do
  c=$(basename "$d"); cd "$root/$c"
  rm -rf slpp_all slpp_unit gold.uhdm ours_b.uhdm ours_p.uhdm
  "$SL" -parse -nopython -d uhdm -top top dut.sv > gold.log 2> gold.err
  g=""
  for cand in slpp_all/surelog.uhdm slpp_unit/surelog.uhdm; do
    [ -s "$cand" ] && g=$cand
  done
  if [ -z "$g" ]; then printf "%-32s %-14s %-14s %s\n" "$c" - - "NO-GOLDEN"; continue; fi
  res=()
  for tag in b p; do
    bin=$BASE; [ $tag = p ] && bin=$PAT
    "$bin" --single-unit --top top dut.sv -o ours_$tag.uhdm > ours_$tag.log 2>&1
    rc=$?
    if [ ! -s ours_$tag.uhdm ]; then
      if [ $rc -ge 128 ]; then res+=("CRASH_rc$rc"); else res+=("NO_DB_rc$rc"); fi
      continue
    fi
    if "$CMP" "$g" ours_$tag.uhdm > cmp_$tag.log 2>&1; then res+=("CMP_EQUAL")
    else res+=("CMP_NOTEQ"); fi
  done
  note=""
  [ "${res[0]}" != "${res[1]}" ] && note="*** DIFFERS ***"
  printf "%-32s %-14s %-14s %s\n" "$c" "${res[0]}" "${res[1]}" "$note"
done
