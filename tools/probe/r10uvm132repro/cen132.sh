#!/bin/bash
# r10uvm132/cen132.sh — MEASUREMENT ONLY.  Re-runs EVERY slang command line a
# verify_golden workdir recorded, under a CENSUS-INSTRUMENTED binary, and
# collects its stderr `CEN132|` rows (one per BUILT-IN METHOD CALL).  The
# instrumented build is not shipped (one env-gated `fprintf` in ExprEmit.cpp's
# built-in-method arm); this driver is, because the TRAPS it encodes are.
#
#   usage:  CEN_BIN=<instrumented binary> cen132.sh <workdir> <out.tsv>
#
# GUARDS, each an ops trap (inherited from r10uvm128repro/cen128.sh):
#   * THE CHILD MUST RUN IN THE TEST'S OWN SOURCE DIRECTORY.  verify_golden.py
#     runs each test with cwd = the test's source dir and does NOT record it in
#     cmds.txt, while the command line names its sources RELATIVELY.  The dir is
#     recovered from sha1(dirpath)[:8] — the hash the workdir name embeds.
#   * the binary comes from CEN_BIN, is PRINTED with its md5, and the rewritten
#     command line is ASSERTED to name it (verify_golden.py and
#     check_goldens.sh both silently default to the MAIN-TREE binary).
#   * the scratch `-o` path is keyed on the RELATIVE workdir path (two modes
#     share every test name; several corpora keep three arms all named dut.sv).
#   * children get </dev/null; LISTED / PROCESSED / SWAPFAIL are printed and
#     must agree, so a driver that reaches nothing cannot read as perfection.
#   * EVERY PARALLEL CHILD WRITES ITS OWN FILE.  A first cut ran the children
#     under one shared `>>` redirect: concurrent appends of multi-kilobyte
#     blocks INTERLEAVED, splicing one row into the middle of another and
#     losing 77 of 1573 workdirs' markers outright (1449 PROCESSED against
#     1523 rows carrying a spliced `RAN`).  A census that reports fewer cells
#     than exist reads exactly like a small population.  Per-child files, then
#     `cat`, and PROCESSED + SKIPPED must equal LISTED.
set -u
WD=${1:?workdir}
OUT=${2:?out file}
CEN_BIN=${CEN_BIN:?set CEN_BIN to the census binary}
SCR=${SCR:-/tmp/r10uvm132_cen/scratch}
DIRMAP=${DIRMAP:-$SCR/dirmap.tsv}
JOBS=${JOBS:-2}
[ -x "$CEN_BIN" ] || { echo "FATAL: no census binary $CEN_BIN"; exit 3; }
mkdir -p "$SCR" || exit 9
if [ ! -f "$DIRMAP" ]; then
  python3 - "$DIRMAP" <<'PY'
import hashlib, os, sys
roots = [os.path.expanduser('~/git-repos/Surelog/tests'),
         os.path.expanduser('~/git-repos/Surelog/third_party/tests'),
         os.path.expanduser('~/git-repos/uhdm2rtlil/test')]
seen = {}
for r in roots:
    for dp, _, _ in os.walk(r):
        seen.setdefault(hashlib.sha1(dp.encode()).hexdigest()[:8], dp)
with open(sys.argv[1], 'w') as f:
    for k, v in seen.items():
        f.write(k + '\t' + v + '\n')
PY
fi
echo "# census binary: $CEN_BIN ($(md5sum "$CEN_BIN" | cut -c1-32))" > "$OUT"
export CEN_BIN SCR DIRMAP WD
run_one() {
  c=$1
  d=$(dirname "$c"); rel=${d#"$WD"/}; mode=${rel%%/*}; test=$(basename "$d")
  line=$(sed -n 's/^slang: *//p' "$c" | head -1)
  [ -n "$line" ] || { echo "SKIPNOLINE $rel" >> "$SCR/marks.$(echo "$rel" | tr '/' '_').txt"; return 0; }
  o=$SCR/$(echo "$rel" | tr '/' '_').uhdm
  new=$(printf '%s' "$line" | sed -e "s#^[^ ]*#$CEN_BIN#" -e "s#-o [^ ]*#-o $o#")
  case "$new" in "$CEN_BIN "*) : ;; *) echo "SWAPFAIL $rel" >> "$SCR/marks.$(echo "$rel" | tr '/' '_').txt"; return 0 ;; esac
  srcdir=$(awk -F'\t' -v h="${test##*-}" '$1==h{print $2; exit}' "$DIRMAP")
  [ -n "$srcdir" ] || { echo "NODIR $rel" >> "$SCR/marks.$(echo "$rel" | tr '/' '_').txt"; return 0; }
  ( cd "$srcdir" && export CEN132=1 && eval "timeout 600 $new" ) </dev/null 2>&1 >/dev/null \
    | sed -n "s#^CEN132|#$test\t$mode\t#p" > "$SCR/part.$(echo "$rel" | tr '/' '_').txt"
  rm -f "$o"
  echo "RAN $rel" >> "$SCR/marks.$(echo "$rel" | tr '/' '_').txt"
}
export -f run_one
find "$WD" -name cmds.txt | sort > "$SCR/list.$$"
n=$(wc -l < "$SCR/list.$$")
rm -f "$SCR"/part.*.txt "$SCR"/marks.*.txt
xargs -a "$SCR/list.$$" -I{} -P "$JOBS" bash -c 'run_one "$@"' _ {} >/dev/null 2>/dev/null
cat "$SCR"/part.*.txt >> "$OUT" 2>/dev/null
cat "$SCR"/marks.*.txt > "$SCR/marks.all" 2>/dev/null
ran=$(grep -c '^RAN ' "$SCR/marks.all"; true)
skip=$(grep -c '^SKIPNOLINE ' "$SCR/marks.all"; true)
fail=$(grep -c '^SWAPFAIL \|^NODIR ' "$SCR/marks.all"; true)
echo "# LISTED $n PROCESSED $ran SKIPPED-NO-SLANG-LINE $skip SWAPFAIL/NODIR $fail" >> "$OUT"
echo "LISTED $n PROCESSED $ran SKIPPED-NO-SLANG-LINE $skip SWAPFAIL/NODIR $fail"
[ $((ran+skip+fail)) -eq "$n" ] || { echo "FATAL: PROCESSED+SKIPPED+FAIL != LISTED"; exit 4; }
rm -f "$SCR/list.$$" "$SCR"/part.*.txt "$SCR"/marks.*.txt
