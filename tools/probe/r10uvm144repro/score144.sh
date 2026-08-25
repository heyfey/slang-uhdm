#!/usr/bin/env bash
# r10uvm144 — score ONE arm dir: for each view, list every call-argument
# ref_obj (name, line, bound-actual KIND) out of golden / pristine / patched and
# print the cell counts.  MEASUREMENT ONLY — the judge is the official uhdm-cmp.
#   usage: score144.sh <armdir>
set -u
D=$(readlink -f "${1:?armdir}")
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
SC=${ARGSCAN:-$(dirname "$(readlink -f "$0")")/argscan144.py}
for f in g o q ge oe qe; do
  [ -f "$D/$f.uhdm" ] || continue
  "$DUMP" "$D/$f.uhdm" > "$D/$f.dump" 2>/dev/null
  python3 "$SC" "$D/$f.dump" full | sort > "$D/$f.args"
done
for v in "g o q DEF" "ge oe qe ELAB"; do
  set -- $v
  [ -f "$D/$1.args" ] || continue
  pw=$(diff "$D/$1.args" "$D/$2.args" | grep -c '^< ROW'; true)
  qw=$(diff "$D/$1.args" "$D/$3.args" | grep -c '^< ROW'; true)
  n=$(grep -c '^ROW' "$D/$1.args"; true)
  echo "$4 cells=$n  PRISTINE-wrong=$pw  PATCHED-wrong=$qw"
  diff "$D/$1.args" "$D/$3.args" | sed "s/^/$4 REMAIN /"
done
