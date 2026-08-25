#!/bin/bash
# r10uvm128/cen128.sh — MEASUREMENT ONLY.  Re-runs EVERY slang command line a
# verify_golden workdir recorded, under a CENSUS-INSTRUMENTED binary, and
# collects its stderr rows.  The instrumented builds are not shipped (they carry
# one `fprintf` inside `ExprEmit.cpp`'s built-in-method arm, plus an
# instrument-only env kill switch for the law); this driver is, because the
# TRAPS it encodes are the reusable part.
#
#   usage:  CEN_BIN=<instrumented binary> [NOFIX=1] cen128.sh <workdir> <out.tsv>
#
# GUARDS, each an ops trap this pass paid for:
#   * THE CHILD MUST RUN IN THE TEST'S OWN SOURCE DIRECTORY.  `verify_golden.py`
#     runs each test with `cwd=dirpath` and does NOT record that path in
#     cmds.txt, while the command line names its sources RELATIVELY.  A driver
#     that `cd`s to the WORKDIR compiles nothing ("error: no input files"),
#     collects no rows, and reports the population as 2 cells instead of 7.
#     The source dir is recovered from `sha1(dirpath)[:8]` — the same hash the
#     workdir directory name embeds — and every workdir must find one.
#   * the binary is taken from CEN_BIN, PRINTED with its md5, and the rewritten
#     command line is ASSERTED to name it (nothing may default to a main-tree
#     binary, which both verify_golden.py and check_goldens.sh silently do).
#   * the scratch `-o` path is keyed on the RELATIVE workdir path: two modes
#     share every test name and three arms in this corpus are all `dut.sv`.
#   * children get `</dev/null`; LISTED / PROCESSED / SWAPFAIL are printed and
#     must agree, so a driver that reaches nothing cannot read as perfection.
set -u
WD=${1:?workdir}
OUT=${2:?out file}
CEN_BIN=${CEN_BIN:?set CEN_BIN to the census binary}
SCR=${SCR:-/tmp/r10uvm128_cen/scratch}
DIRMAP=${DIRMAP:-$SCR/dirmap.tsv}
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
n=0; ran=0; fail=0
while IFS= read -r c; do
  d=$(dirname "$c"); rel=${d#"$WD"/}; mode=${rel%%/*}; test=$(basename "$d")
  line=$(sed -n 's/^slang: *//p' "$c" | head -1)
  [ -n "$line" ] || continue
  n=$((n+1))
  o=$SCR/$(echo "$rel" | tr '/' '_').uhdm
  new=$(printf '%s' "$line" | sed -e "s#^[^ ]*#$CEN_BIN#" -e "s#-o [^ ]*#-o $o#")
  case "$new" in "$CEN_BIN "*) : ;; *) echo "FATAL: binary swap failed for $rel" >> "$OUT"; fail=$((fail+1)); continue ;; esac
  srcdir=$(awk -F'\t' -v h="${test##*-}" '$1==h{print $2; exit}' "$DIRMAP")
  [ -n "$srcdir" ] || { echo "FATAL: no source dir for $rel" >> "$OUT"; fail=$((fail+1)); continue; }
  ( cd "$srcdir" && export SLANG_UHDM_CEN128=1
    [ -n "${NOFIX:-}" ] && export SLANG_UHDM_NOFIX128=1
    eval "timeout 300 $new" ) </dev/null 2>&1 >/dev/null \
    | sed -n -e 's/^CEN128\t/CEN\t/p' -e 's/^DROP128\t/DROP\t/p' | while IFS= read -r r; do
        printf '%s\t%s\t%s\n' "$test" "$mode" "$r" >> "$OUT"
      done
  ran=$((ran+1)); rm -f "$o"
done < <(find "$WD" -name cmds.txt | sort)
echo "# LISTED $n PROCESSED $ran SWAPFAIL $fail" >> "$OUT"
echo "LISTED $n PROCESSED $ran SWAPFAIL $fail"
