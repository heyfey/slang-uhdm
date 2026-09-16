#!/usr/bin/env bash
# r11u51 GRID SCORER.  Prints, for every road cell, what each producer put at
# the named SOURCE SITE in each VIEW.  Re-runs the grid first (run51.sh leaves
# the dumps in place; the committed tree keeps only dut.sv + rc + cmp.err, so
# this script is the way to regenerate the evidence).
#
#   usage: score51.sh <binary>          (default: the main tree's build)
#
# The VIEW sectioning is the whole point: the producer compiles a module TWICE
# (definition with no instance, then once per instance) and a package TWICE
# (Reduce::Yes then Reduce::No), so "golden folds" is never a whole-design
# fact.  DEF = the uhdmall* listing, ELAB = the uhdmtop* listing, TAIL = the
# weaklyReferenced tail (reachable to the judge only through a ref_typespec).
set -u
D=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BIN=${1:-/home/heyfey/git-repos/slang-uhdm/build/slang-uhdm}
bash "$D/run51.sh" "$BIN" base
echo
echo "=== ROAD A — \$bits argument kind x holder x view (a1/a2/a3)"
bash "$D/cell51.sh" a1_bits_argkind base 15:23 16:23 17:23 18:23 19:23 20:23
bash "$D/cell51.sh" a3_bits_iface  base 7:24 8:24
echo
echo "=== ROAD B — leaf substitution inside a package parameter (b1/b2/b3)"
for a in b1_leafsubst_pkg b2_leafsubst_mod b3_leafsubst_ca; do
  echo "-- $a: ref_obj survivals per view"
  for side in gold ours; do
    printf "   %-6s " "$side"
    awk '/uhdmtop(Packages|Modules):/{e=NR} /ref_obj: \(pk::C[03]\)/{printf "%s@%s ", $0, (e?"ELAB":"DEF")}' \
        "$D/grid/$a/$side.base.dump" | sed 's/\\_//g;s/, line[^ ]*//g'; echo
  done
done
echo
echo "=== ROAD C — a typedef's ELEMENT bound (c1/c2/c3)"
for a in c1_typedef_mod c2_typedef_pkg c3_typedef_iface; do
  echo "-- $a: symbolic bounds each side carries"
  for side in gold ours; do
    printf "   %-6s " "$side"
    grep -o "ref_obj: ([^)]*\(NDATA\|DATA_SIZE\|DEPTH\)), line:[0-9:]*" "$D/grid/$a/$side.base.dump" \
      | sed 's/ref_obj: //' | sort | uniq -c | tr '\n' ' '; echo
  done
done
echo
echo "=== ROAD D — an elaborated pattern element's SIZE (d1/d2/d3)"
for a in d1_cast_pkg d2_cast_mod; do
  echo "-- $a"
  for side in gold ours; do
    echo "   $side:"
    grep -n "constant: , line:[89]:\|constant: , line:1[01]:" "$D/grid/$a/$side.base.dump" |
    while IFS=: read -r ln rest; do
      sz=$(sed -n "$((ln+1)),$((ln+6))p" "$D/grid/$a/$side.base.dump" | sed -n 's/.*vpiSize:\([0-9]*\).*/\1/p' | head -1)
      par=$(sed -n "$((ln+1)),$((ln+3))p" "$D/grid/$a/$side.base.dump" | sed -n 's/.*\\_\([a-z_]*\):.*/\1/p' | head -1)
      echo "     site=$(echo "$rest" | sed 's/.*line://;s/,.*//') size=${sz:-?} parent=${par:-<pattern>}"
    done
  done
done
echo
echo "=== ROAD E — the elaborated cont_assign Rhs (e1/e2/e3)"
for a in e1_ca_rhskind e2_ca_lhskind e3_ca_structparam; do
  echo "-- $a: elaborated cont_assign Rhs per side ('(shared)' = the def object reused)"
  for side in gold ours; do
    echo "   $side:"
    st=$(grep -n uhdmtopModules "$D/grid/$a/$side.base.dump" | head -1 | cut -d: -f1)
    awk -v st="$st" 'NR>st && /cont_assign: , line:/{site=$0; sub(/.*line:/,"",site); sub(/,.*/,"",site);
        getline a; if(a ~ /vpiParent/){getline;getline;getline;
          k=$0; sub(/^ *\\_/,"",k); sub(/:.*/,"",k); print "     "site" -> "k}
        else print "     "site" -> (shared)"}' "$D/grid/$a/$side.base.dump"
  done
done
