#!/usr/bin/env bash
# vrgg9 boundary: compile EVERY .sv/.v under the named repro dirs with N binaries
# and compare databases byte-wise.  SUBDIRECTORY arms included (find), children
# get </dev/null, rc is RECORDED per file per binary, the file LIST is emitted on
# fd 3, and a POSITIVE CONTROL asserts the driver actually reached files.
set -u
A=${1:?bin A}; B=${2:?bin B}; OUT=${3:?out}; shift 3
same=0; diff=0; nocomp=0; asym=0; n=0; seg=0
exec 3>"$OUT.list"
{
for d in "$@"; do
  [ -d "$d" ] || { echo "MISSING-DIR $d"; continue; }
  while IFS= read -r f; do
    n=$((n+1)); echo "$f" >&3
    wa=/tmp/vrgg9_bnd_a.$$.uhdm; wb=/tmp/vrgg9_bnd_b.$$.uhdm
    rm -f "$wa" "$wb"
    (cd "$(dirname "$f")" && "$A" "$(basename "$f")" --single-unit -o "$wa" >/dev/null 2>&1 </dev/null); ra=$?
    (cd "$(dirname "$f")" && "$B" "$(basename "$f")" --single-unit -o "$wb" >/dev/null 2>&1 </dev/null); rb=$?
    [ "$ra" = 139 ] && { seg=$((seg+1)); echo "SEGFAULT-A $f"; }
    [ "$rb" = 139 ] && { seg=$((seg+1)); echo "SEGFAULT-B $f"; }
    echo "RC $f $ra $rb" >&3
    if [ ! -f "$wa" ] && [ ! -f "$wb" ]; then
      echo "UNCOMPILABLE $f (rc $ra/$rb)"; nocomp=$((nocomp+1))
    elif [ ! -f "$wa" ] || [ ! -f "$wb" ]; then
      echo "ASYMMETRY $f (rc A=$ra B=$rb)"; asym=$((asym+1))
    elif cmp -s "$wa" "$wb"; then same=$((same+1))
    else echo "MOVER $f"; diff=$((diff+1)); fi
    rm -f "$wa" "$wb"
  done < <(find "$d" -type f \( -name '*.sv' -o -name '*.v' \) | sort)
done
echo "-- files=$n identical=$same MOVERS=$diff uncompilable=$nocomp asymmetries=$asym SEGFAULT=$seg"
[ "$n" -gt 0 ] && echo "POSITIVE-CONTROL: driver reached $n files" || echo "POSITIVE-CONTROL FAILED: reached 0 files"
[ "$same" -gt 0 ] && echo "POSITIVE-CONTROL: $same files compiled by BOTH binaries" || echo "POSITIVE-CONTROL FAILED: no file compiled by both"
} > "$OUT" 2>&1
exec 3>&-
