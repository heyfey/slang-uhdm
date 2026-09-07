#!/usr/bin/env bash
# r10uvm187 — PREDICT THE MOVER SET BY NAME, from PRISTINE DATABASES ONLY.
# MEASUREMENT ONLY; the official uhdm-cmp and verify_golden.py are the judges.
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# For every test in a verify_golden workdir this runs ct187cen over the GOLDEN
# database and over the PRISTINE `slang.uhdm`, joins the two parameter censuses
# on (view|owner|param|loc|kind), and prints one CELL line per cell whose GOLDEN
# side carries THIS law's shape --
#
#     a package-listing `parameter` whose typespec actual is an
#     int_/byte_/bit_typespec with rg=0, a BARE VpiName (no `::`), a
#     `Typedef_alias`, and vpiParent == the parameter  (i.e. a per-declaration
#     NAMED CLONE of a scalar typedef)
#
# -- and whose OURS side disagrees.  The TESTS those cells belong to are the
# predicted movers, printed as a sorted name list.
#
# GUARDS: a missing golden or a missing slang.uhdm is COUNTED and printed as
# SKIP, never silently dropped (uhdm-cmp exits 0 on a missing input and this
# campaign has been burned by a driver that reached nothing and read green);
# the golden cache DIRECTORY is turned into .../golden.uhdm.
#
#   usage: CEN=<path to ct187cen> predict187.sh <workdir> <outfile>
set -u
WD=$(readlink -f "${1:?workdir}")
OUT=${2:?outfile}
CEN=${CEN:?path to ct187cen}
[ -x "$CEN" ] || { echo "FATAL: no ct187cen at $CEN"; exit 3; }
: > "$OUT"
tests=0; skip=0; cells=0
for d in "$WD"/*/*/; do
  [ -f "$d/cmds.txt" ] || continue
  tests=$((tests+1))
  mode=$(basename "$(dirname "$d")")
  name=$(basename "$d"); name=${name%-*}
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$d/slang.uhdm" ]; then
    echo "SKIP	$name	$mode" >> "$OUT"; skip=$((skip+1)); continue
  fi
  "$CEN" "$G"             2>/dev/null | awk -F'\t' '{print $1"|"$2"|"$3"|"$4"|"$5"\t"$6}' | sort > /tmp/.p187g.$$
  "$CEN" "$d/slang.uhdm"  2>/dev/null | awk -F'\t' '{print $1"|"$2"|"$3"|"$4"|"$5"\t"$6}' | sort > /tmp/.p187o.$$
  join -t$'\t' -j1 /tmp/.p187g.$$ /tmp/.p187o.$$ |
    awk -F'\t' -v n="$name" -v m="$mode" '
      $1 ~ /^(DEFPKG|ELABPKG)\|/ &&
      $2 != $3 &&
      $2 ~ /^(int_typespec|byte_typespec|bit_typespec)\(/ &&
      $2 !~ /^[a-z_]*typespec\(\)/ &&
      substr($2, index($2,"(")+1, index($2,")")-index($2,"(")-1) !~ /::/ &&
      $2 ~ /\[alias->/ &&
      $2 ~ /rg=0/ &&
      $2 ~ /apar=parameter/ {
        print "CELL\t" n "\t" m "\t" $1 "\n    gold " $2 "\n    ours " $3
      }' >> "$OUT"
  rm -f /tmp/.p187g.$$ /tmp/.p187o.$$
done
cells=$(grep -c '^CELL' "$OUT"; true)
echo "-- SCANNED=$tests SKIP=$skip PREDICTED-CELLS=$cells"
echo "-- PREDICTED-MOVER TESTS:"
grep '^CELL' "$OUT" | cut -f2,3 | sort -u
echo "-- PREDICTED-MOVER TEST NAMES:"
grep '^CELL' "$OUT" | cut -f2 | sort -u | tr '\n' ' '; echo
