#!/usr/bin/env bash
# r10uvm163 — run ct163cen over EVERY `slang.uhdm` in a verify_golden workdir
# (OURS side, PRISTINE) and print the per-DATABASE candidate listing, so the
# mover set can be named BY NAME before the patched sweep runs.
# MEASUREMENT ONLY.  LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.
#   usage: CT163CEN=<bin> predsweep163.sh <workdir> <outdir>
# GUARDS:
#   * ct163cen exits 4 on a database with ZERO class_typespec (most uhdm2rtlil
#     rows have no classes at all); that is EXPECTED here and is COUNTED as
#     NOCLASS, not silently treated as "no candidates";
#   * a RESTORE_FAIL is counted separately and printed;
#   * the database COUNT walked is printed, so a driver that reached nothing
#     cannot read as clean.
set -u
WD=${1:?workdir}; OUT=${2:?outdir}
CEN=${CT163CEN:?set CT163CEN}
[ -x "$CEN" ] || { echo "FATAL: no ct163cen at $CEN"; exit 3; }
mkdir -p "$OUT" || exit 1
n=0; noclass=0; fail=0; withcells=0
: > "$OUT/list.txt"
while IFS= read -r db; do
  n=$((n+1))
  rel=${db#"$WD"/}; rel=${rel%/slang.uhdm}
  # key the scratch on the RELATIVE path: several arms/rows share a basename
  tag=$(printf '%s' "$rel" | tr '/' '_')
  "$CEN" ${CEN_ARGS:-} "$db" > "$OUT/$tag.cen" 2>&1; rc=$?
  case $rc in
    0) withcells=$((withcells+1)); echo "$OUT/$tag.cen" >> "$OUT/list.txt" ;;
    4) noclass=$((noclass+1)); rm -f "$OUT/$tag.cen" ;;
    *) fail=$((fail+1)); echo "CENFAIL rc=$rc $rel" ;;
  esac
done < <(find "$WD" -name slang.uhdm | sort)
echo "-- databases=$n WITH-CLASS-TYPESPEC=$withcells NOCLASS=$noclass CENFAIL=$fail"
