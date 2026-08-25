#!/usr/bin/env bash
# r10earl89 — THE MOVER PREDICTION, made with the NEUTRAL binary.
#
# Re-runs each test's OWN slang command line (read out of the pristine sweep's
# `cmds.txt`, in the test's OWN source directory — the harness runs slang with
# `cwd=dirpath`, recovered from the workdir's `sha1(dirpath)[:8]` suffix) with
# the PATCHED binary under `R10E89_OFF=1`, whose database is BYTE-IDENTICAL to
# the pristine one, and `R10E89_CELLDBG=1`, which prints the OLD and the NEW
# typespec answer for EVERY unpacked size-form dimension the two arms reach —
# including rows the law would change BY ACCIDENT (earl66's rule).  Output goes
# to /dev/null, so nothing this driver runs can move a database.
#
# THE FOUR SLANG-FENCED TESTS ARE NEVER DISPATCHED: only command lines that
# ALREADY RAN in the pristine sweep are re-run, and those four are not in it.
#   usage: NEUTRAL=<binary> DIRMAP=<map> predict89.sh <pristine-workdir> <out>
set -u
BIN=${NEUTRAL:?set NEUTRAL}
MAP=${DIRMAP:?set DIRMAP}
WD=$(readlink -f "$1"); OUT=$(readlink -f "$2")
rm -f "$OUT" "$OUT".part.*
run_one() {
  c="$1"; d=$(dirname "$c"); rel=${d#"$WD"/}
  h=${d##*-}
  src=$(awk -v h="$h" '$1==h {print $2; exit}' "$MAP")
  [ -n "$src" ] || { echo "NOSRC $rel" >> "$OUT".part.$$; return 0; }
  line=$(grep -m1 '^slang:' "$c" | sed 's/^slang: *//')
  [ -n "$line" ] || return 0
  args=$(printf '%s' "$line" | sed "s|^[^ ]*|$BIN|; s|-o [^ ]*|-o /dev/null|")
  ( cd "$src" && R10E89_OFF=1 R10E89_CELLDBG=1 timeout 900 sh -c "$args" \
      >/dev/null 2>/tmp/r10earl89_pred.$$ </dev/null )
  rc=$?
  grep -h '^R10E89 ' /tmp/r10earl89_pred.$$ 2>/dev/null |
      sed "s|^|$rel rc=$rc |" >> "$OUT".part.$$
  rm -f /tmp/r10earl89_pred.$$
}
export -f run_one; export BIN WD OUT MAP
find "$WD" -name cmds.txt | sort | xargs -P 2 -I{} bash -c 'run_one "$@"' _ {}
cat "$OUT".part.* > "$OUT" 2>/dev/null; rm -f "$OUT".part.*
echo "trace_lines=$(grep -c '^' "$OUT"; true)"
echo "NOSRC=$(grep -c '^NOSRC' "$OUT"; true)"
echo "CHANGED=$(grep -cE 'tsOld=0 tsNew=1|tsOld=1 tsNew=0' "$OUT"; true)"
echo "RED-ADDS=$(grep -c 'RED .*tsOld=0 tsNew=1' "$OUT"; true)"
