#!/usr/bin/env bash
# r10uvm167repro/armjudge167.sh — put the OFFICIAL JUDGE on every grid arm.
#
#   armjudge167.sh <grid workdir> [<grid workdir> ...]
#
# The census families in score167.py are INSTRUMENTS.  `uhdm-cmp` is the judge,
# and this driver runs it golden-vs-PRISTINE and golden-vs-PATCHED on both views
# of every arm, so the arm's verdict is a cmp-line count and a head, not a
# census opinion.  uhdm-cmp EXITS 0 WHEN AN INPUT IS MISSING, so both sides are
# existence-checked and a missing side is COUNTED, never silently skipped; the
# head is counted with `grep -c '^LHS:'` anchored at column 0 (cmp prints
# `decompile:` twice per side for ONE head), and cmp's own rc is captured
# immediately.
set -u
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
[ -x "$CMP" ] || { echo "FATAL: no uhdm-cmp at $CMP"; exit 3; }
printf "%-22s %-5s %10s %10s %7s %7s\n" ARM VIEW PRIS_LINES PAT_LINES P_HEADS Q_HEADS
miss=0
for W in "$@"; do
  n=$(basename "$W")
  for v in def elab; do
    G=$W/g_$v/slpp_all/surelog.uhdm
    A=$W/a_$v.uhdm
    B=$W/b_$v.uhdm
    if [ ! -f "$G" ] || [ ! -f "$A" ] || [ ! -f "$B" ]; then
      printf "%-22s %-5s %10s %10s %7s %7s  SKIP-NOFILE\n" "$n" "$v" - - - -
      miss=$((miss+1)); continue
    fi
    "$CMP" "$G" "$A" > "$W/cmp.a.$v.txt" 2>&1; arc=$?
    "$CMP" "$G" "$B" > "$W/cmp.b.$v.txt" 2>&1; brc=$?
    printf "%-22s %-5s %10s %10s %7s %7s  rc=%s/%s\n" "$n" "$v" \
      "$(wc -l < "$W/cmp.a.$v.txt")" "$(wc -l < "$W/cmp.b.$v.txt")" \
      "$(grep -c '^LHS:' "$W/cmp.a.$v.txt")" "$(grep -c '^LHS:' "$W/cmp.b.$v.txt")" \
      "$arc" "$brc"
  done
done
echo "-- SKIP-NOFILE=$miss"
