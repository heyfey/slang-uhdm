#!/usr/bin/env bash
# r10uvm222 — THE ARM SCORER, official judge.  MEASUREMENT ONLY.
#
# Runs the OFFICIAL uhdm-cmp on each grid arm with GOLDEN AS LHS (the standing
# law) for the PRISTINE and the PATCHED grid runs side by side, so an arm that
# moved can be read as TOWARD or AWAY without argument.  cmp writes its head to
# STDERR, so stderr is KEPT (a `2>/dev/null` once made every head counter read
# zero); the rc is printed because a cmp that fell over must never read as
# agreement, and an arm whose slang side has no database at all is printed
# NODB rather than skipped.
#
#   usage: armscore222.sh <pristine-griddir> <patched-griddir>
set -u
P=${1:?pristine griddir}; Q=${2:?patched griddir}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
[ -x "$CMP" ] || { echo "FATAL: no uhdm-cmp at $CMP"; exit 3; }
printf "%-12s %10s %6s %10s %6s  %s\n" ARM PRIS_LINES HEADS PAT_LINES HEADS VERDICT
for a in $(cd "$P" && ls -d */ | tr -d /); do
  pg=$P/$a/g/slpp_all/surelog.uhdm; po=$P/$a/o/slang.uhdm
  qg=$Q/$a/g/slpp_all/surelog.uhdm; qo=$Q/$a/o/slang.uhdm
  if [ ! -f "$po" ] || [ ! -f "$qo" ]; then
    printf "%-12s %10s %6s %10s %6s  %s\n" "$a" - - - - \
      "NODB (slang produced none — an ERROR-RECOVERY arm, not a golden one)"
    continue
  fi
  "$CMP" "$pg" "$po" > "$P/$a/cmp.txt" 2>&1; prc=$?
  "$CMP" "$qg" "$qo" > "$Q/$a/cmp.txt" 2>&1; qrc=$?
  pl=$(wc -l < "$P/$a/cmp.txt"); ph=$(grep -c '^LHS:' "$P/$a/cmp.txt"); true
  ql=$(wc -l < "$Q/$a/cmp.txt"); qh=$(grep -c '^LHS:' "$Q/$a/cmp.txt"); true
  v=UNCHANGED
  [ "$pl" != "$ql" ] && v=MOVED
  printf "%-12s %10s %6s %10s %6s  %s rc=%s/%s\n" "$a" "$pl" "$ph" "$ql" "$qh" "$v" "$prc" "$qrc"
done
