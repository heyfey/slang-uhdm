#!/usr/bin/env bash
# r10earl69 — score a DIRECTORY-unit boundary difference against golden, the
# same judge-faithful way vscore69.sh scores a single file.
#   usage: HPNAME=... vdirscore69.sh <dir-list> <outdir>
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
HP=${HPNAME:?}; PAT=${PATCHED_BIN:?}; PRIS=${PRISTINE_BIN:?}
LIST=${1:?}; OUT=${2:?}; mkdir -p "$OUT"
norm() { sed -E 's/span=[^ ,;}]*:([0-9]+:[0-9]+-[0-9]+:[0-9]+)/span=\1/g'; }
while read -r dir <&3; do
  key=$(echo "${dir#/}" | tr '/' '_'); d="$OUT/$key"; mkdir -p "$d"
  cp "$dir"/*.sv "$d/" 2>/dev/null || continue
  ( cd "$d" && "$SL" -parse -nobuiltin -nocache -d uhdm *.sv >sl.log 2>&1 </dev/null )
  [ -f "$d/slpp_all/surelog.uhdm" ] || { echo "NOGOLD $dir"; continue; }
  "$HP" "$d/slpp_all/surelog.uhdm" 2>/dev/null | norm > "$d/g.hp"
  for s in pris pat; do
    bin=$PRIS; [ $s = pat ] && bin=$PAT
    for v in plain elab; do
      fl=""; [ $v = elab ] && fl="--elabuhdm"
      ( cd "$d" && "$bin" $fl *.sv -o $s$v.uhdm >$s$v.log 2>&1 </dev/null )
      [ -f "$d/$s$v.uhdm" ] && "$HP" "$d/$s$v.uhdm" 2>/dev/null | norm > "$d/$s$v.hp" || : > "$d/$s$v.hp"
    done
  done
  echo "DIR $dir"
  python3 "$(dirname "$0")/armscore69.py" "$d/g.hp" "$d/prisplain.hp" "$d/patplain.hp" "$d/priselab.hp" "$d/patelab.hp"
done 3< "$LIST"
