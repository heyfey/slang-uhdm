#!/usr/bin/env bash
# r10sd6 VERIFIER — DETERMINISM ON A CORPUS ROW, not on a 20-line cell.
#
# `detcheck.sh` answers "does this binary reproduce its own bytes" and the
# implementer ran it on grid cell `g6` (a 20-line file, 10 212 bytes).  That is
# not where the campaign's known nondeterminism lives.  This driver runs the
# SAME question on a CORPUS row, using the row's own argv out of the sweep's
# `cmds.txt`, from the row's own directory (verify_golden.py runs slang with
# cwd=dirpath and the relative sources do not resolve from anywhere else).
#
#   usage: vsd6det.sh <bin> <N> <testdir> <argv...>
#
# It prints md5 AND SIZE for every run, because they answer different questions:
#   md5 unstable + size stable  -> ARENA-ORDER noise; a byte comparator will
#                                  report this row as a mover against ITSELF,
#                                  so `byteverify.sh`'s md5 verdict is unsound
#                                  here and only the SIZE delta carries.
#   size unstable               -> content nondeterminism; nothing carries.
# MEASURED at BASE e07cb9c: Scoreboard/default gives 3 distinct md5s in 5 runs
# at ONE size (11 138 212).  SeqDriver and SimpleUVM give 1 distinct md5 in 3.
set -u
BIN=${1:?bin}; N=${2:?runs}; DIR=${3:?test dir}; shift 3
[ -x "$BIN" ] || { echo "FATAL: no bin $BIN"; exit 3; }
[ -d "$DIR" ] || { echo "FATAL: no dir $DIR"; exit 3; }
echo "BIN=$BIN md5=$(md5sum "$BIN" | cut -d' ' -f1)  runs=$N  dir=$DIR"
T=$(mktemp -d /tmp/vsd6det.XXXXXX)
bad=0
cd "$DIR" || exit 3
for i in $(seq 1 "$N"); do
  "$BIN" "$@" -o "$T/db$i.uhdm" > "$T/log$i" 2>&1
  if [ ! -s "$T/db$i.uhdm" ]; then echo "run $i: NO_OUTPUT"; bad=$((bad+1)); continue; fi
  echo "run $i: md5=$(md5sum "$T/db$i.uhdm" | cut -c1-16)  bytes=$(stat -c %s "$T/db$i.uhdm")"
done
H=$(md5sum "$T"/db*.uhdm 2>/dev/null | cut -d' ' -f1 | sort -u | wc -l)
S=$(stat -c %s "$T"/db*.uhdm 2>/dev/null | sort -u | wc -l)
echo "distinct md5=$H  distinct sizes=$S  NO_OUTPUT=$bad"
[ "$H" -eq 1 ] && echo "DETERMINISTIC" || {
  [ "$S" -eq 1 ] && echo "ARENA-ORDER NONDETERMINISM (size stable): md5 movers on this row are NOISE" \
                 || echo "CONTENT NONDETERMINISM: no byte reading on this row means anything"; }
rm -rf "$T"
