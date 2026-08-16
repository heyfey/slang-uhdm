#!/usr/bin/env bash
# r10earl48 — the NAMED-DATABASE canary check, BY NAME, with the r10earl46 trap
# closed: `cmp` on two MISSING files exits non-zero and reads exactly like a
# mover, so every name must EXIST on both sides or be reported ABSENT.
set -u
A=$1; B=$2; shift 2
ok=0; moved=0; absent=0
for n in "$@"; do
  found=0
  while read -r p; do
    found=1
    if [ ! -f "$B/$p" ]; then echo "ABSENT-PRISTINE $p"; absent=$((absent+1)); continue; fi
    if cmp -s "$A/$p" "$B/$p"; then ok=$((ok+1)); else echo "MOVED $p"; moved=$((moved+1)); fi
  done < <(cd "$A" && find . -path "*${n}-*/slang.uhdm" | sort)
  [ $found -eq 1 ] || { echo "NO-DATABASE $n (SLANG_REJECT or not in this corpus)"; }
done
echo "byname: identical=$ok moved=$moved absent=$absent"
