#!/usr/bin/env bash
# r10uvm98 — MEASUREMENT ONLY.  Attribute one mover: the whole-dump,
# path-normalised, id-stripped diff between the pristine and the patched
# database, ORDERED and ORDER-BLIND (Scoreboard/default is a known ~50/50 coin,
# so only the order-blind count is attributable there).
#   ./attrib98.sh <rel/path/slang.uhdm> <patched wd> <pristine wd> [outdir]
set -u
REL=${1:?rel}; A=${2:?patched wd}; B=${3:?pristine wd}; OUT=${4:-/tmp/r10uvm98_attr}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
mkdir -p "$OUT" || exit 9
key=$(echo "$REL" | sed 's#[^A-Za-z0-9._-]#_#g')
norm() {  # strip object ids and the workdir path so the two dumps are comparable
  sed -e 's/, id:[0-9]*//g' -e 's#/tmp/r10uvm98_wd/[a-z0-9_]*/#WD/#g'
}
"$DUMP" "$B/$REL" 2>/dev/null </dev/null | sed 1d | norm > "$OUT/$key.pris"
"$DUMP" "$A/$REL" 2>/dev/null </dev/null | sed 1d | norm > "$OUT/$key.pat"
o=$(diff "$OUT/$key.pris" "$OUT/$key.pat" | grep -cE '^[<>]'; true)
sort "$OUT/$key.pris" > "$OUT/$key.pris.s"; sort "$OUT/$key.pat" > "$OUT/$key.pat.s"
ob=$(diff "$OUT/$key.pris.s" "$OUT/$key.pat.s" | grep -cE '^[<>]'; true)
echo "$REL  ORDERED=$o  ORDER-BLIND=$ob"
