#!/bin/bash
# r10uvm53repro/argcells.sh — arm a4's call-ARGUMENT binding table, BOTH SIDES,
# one line per call site, keyed by the argument's line:col so it can be matched
# against the cell comments in a4/dut.sv.
#
# LHS is ALWAYS golden(Surelog) = g.dump; RHS is ALWAYS ours = o.dump.
#
# GUARDS:
#   * both dumps existence-checked (an empty table must never read as clean);
#   * dumptree.py prints UNMEASURED and exits non-zero when its regex matches no
#     ref_obj, so a mistyped pattern cannot print an empty table quietly;
#   * surelog.log is checked for CP0332 -- pass 52 recorded that Surelog refuses
#     a class method's bare call to a PACKAGE function, which silently poisons
#     this arm; a non-zero count is printed LOUDLY.
set -u
OUT=${1:?gold.sh outdir}
HERE=$(cd "$(dirname "$0")" && pwd)
DT=$HERE/../r10uvm52repro/dumptree.py
[ -f "$DT" ] || { echo "FATAL: missing $DT"; exit 3; }
for f in "$OUT/g.dump" "$OUT/o.dump"; do
  [ -s "$f" ] || { echo "FATAL: missing or empty $f"; exit 3; }
done
if [ -f "$OUT/surelog.log" ]; then
  n=$(grep -c CP0332 "$OUT/surelog.log")
  echo "surelog CP0332 count = $n  (MUST be 0; a non-zero count poisons this arm)"
fi
echo "######## LHS golden(Surelog)"
python3 "$DT" "$OUT/g.dump" refs 'f' | grep -E 'ib_all|ob_all|pk_all' | sort -t@ -k2 || exit 4
echo "######## RHS ours"
python3 "$DT" "$OUT/o.dump" refs 'f' | grep -E 'ib_all|ob_all|pk_all' | sort -t@ -k2 || exit 4
