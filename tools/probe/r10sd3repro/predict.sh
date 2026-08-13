#!/usr/bin/env bash
# r10sd3 CENSUS-PREDICT — which corpus tests can the patch reach, decided from
# the SOURCE before any sweep is read.
#
# The gate is a per-reference return-name LOCAL minted for a CLASS method that
# is (a) inside a package and (b) defined OUT OF BODY.  Two source facts are
# necessary for a row to move:
#   * a `package ... endpackage` block, AND
#   * an out-of-body subroutine definition (`function <ret> C::name` /
#     `task C::name`), which is what `extern` + `::` spells.
# A row with neither cannot reach the changed line at all, so the prediction is
# an UPPER BOUND on the mover set, computed without looking at any artifact.
#
#   usage: predict.sh            # prints the candidate rows, per corpus
set -u
SL=${SURELOG_TESTS:-$HOME/git-repos/Surelog}
U2R=${U2R_TESTS:-$HOME/git-repos/uhdm2rtlil/test}
oob='(function|task)[[:space:]][^;]*[A-Za-z_][A-Za-z0-9_]*::[A-Za-z_]'

# A test that merely COMPILES UVM inherits the shape without spelling it in its
# own directory: uvm_pkg.sv is one package holding ~1000 out-of-body class
# methods.  Any row whose sources mention uvm is a candidate on that ground
# alone — this is how the four UVM rows get predicted, and a scan that only
# reads the test directory misses all four.
scan() { # $1 = root, $2 = label
  local root=$1 label=$2 n=0
  while IFS= read -r d; do
    local why=""
    if grep -rlqiE 'uvm_pkg|uvm_macros|`uvm_' "$d" 2>/dev/null; then
      why=uvm
    elif grep -rlqE '^[[:space:]]*package[[:space:]]' "$d" --include='*.sv' \
           --include='*.svh' --include='*.v' 2>/dev/null &&
         grep -rlqE "$oob" "$d" --include='*.sv' --include='*.svh' \
           --include='*.v' 2>/dev/null; then
      why=pkg-oob
    fi
    if [ -n "$why" ]; then
      echo "$label $(basename "$d") ($why)"
      n=$((n+1))
    fi
  done < <(find "$root" -mindepth 1 -maxdepth 1 -type d | sort)
  echo "$label CANDIDATES=$n" >&2
}

echo "== uhdm2rtlil"
scan "$U2R" u2r
echo "== surelog (third_party/tests + tests)"
for r in "$SL/third_party/tests" "$SL/tests"; do
  [ -d "$r" ] && scan "$r" surelog
done
