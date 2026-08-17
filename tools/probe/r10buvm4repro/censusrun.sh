#!/usr/bin/env bash
# r10buvm4 census driver — replays every corpus test's SLANG argv (built by
# verify_golden.py's own translate()/location_args()/split_sources()) in the
# test's OWN directory, against the CENSUS binary.  Surelog is never run, so
# this reads the whole corpus for a fraction of a sweep.
#
# Each test-mode writes its OWN census file, so a hit is attributable to a ROW
# by NAME rather than to the corpus as a whole, and every test-mode's EXIT CODE
# is recorded: a run that CRASHED has not been censused, and a census that
# silently counted a crash as "no named arguments" would under-report the
# population.  (The first pass wrote -o /dev/null and 6 test-modes SEGFAULTED
# in the database writer; they are re-run here with a real output path.)
#
# FENCE: the four slang-fenced tests are NEVER dispatched.  results/*.csv are
# never touched.
set -u
BIN=${1:?census binary}
TSV=${2:?tests tsv}
OUT=${3:?census output dir}
[ -x "$BIN" ] || { echo "FATAL: no binary $BIN"; exit 3; }
rm -rf "$OUT"; mkdir -p "$OUT/db" || exit 9
export R10BUVM4_BIN=$BIN R10BUVM4_OUT=$OUT
run_one() {
  IFS=$'\t' read -r corpus name mode dirpath args <<< "$1"
  case "$name" in
    UnsignedParam|HierPathEval|FileLocalParam|TopParam)
      echo "FENCED $corpus.$name.$mode"; return;;
  esac
  local tag=$corpus.$name.$mode
  ( cd "$dirpath" 2>/dev/null || exit 9
    R10BUVM4_CENSUS="$R10BUVM4_OUT/$tag.txt" \
      timeout 600 "$R10BUVM4_BIN" $args -o "$R10BUVM4_OUT/db/$tag.uhdm" \
      >/dev/null 2>&1 )
  echo "rc=$? $tag"
}
export -f run_one
cat "$TSV" | xargs -d '\n' -P 2 -I{} bash -c 'run_one "$@"' _ {} > "$OUT/rc.txt"
rm -rf "$OUT/db"
echo "-- exit codes:"; awk '{print $1}' "$OUT/rc.txt" | sort | uniq -c
echo "-- NON-ZERO test-modes:"; grep -v '^rc=0 ' "$OUT/rc.txt" | grep -v '^FENCED' || true
echo "-- census files with hits: $(ls "$OUT" | grep -c '\.txt$')"
