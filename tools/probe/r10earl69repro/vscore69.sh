#!/usr/bin/env bash
# r10earl69 — SCORE every boundary-differing arm AGAINST GOLDEN.  The wide/dir
# boundaries only say "the two binaries disagree here"; this says WHICH WAY.
# Surelog builds the golden for each file, then the hier_path NAME census is
# scored JUDGE-FAITHFULLY (Path_elems first — `hier_path::Compare` reads them
# before VpiName, so a name change on a cell whose elements already differ is
# unreachable to the judge and is scored STILL-WRONG(ELEMS-DIFFER)).
#   usage: HPNAME=... vscore69.sh <file-list> <outdir>
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
HP=${HPNAME:?}
PAT=${PATCHED_BIN:?}; PRIS=${PRISTINE_BIN:?}
LIST=${1:?}; OUT=${2:?}
mkdir -p "$OUT"
norm() { sed -E 's/span=[^ ,;}]*:([0-9]+:[0-9]+-[0-9]+:[0-9]+)/span=\1/g'; }
while read -r f <&3; do
  key=$(echo "${f#/}" | tr '/' '_'); key=${key%.sv}
  d="$OUT/$key"; mkdir -p "$d"; cp "$f" "$d/" || continue
  b=$(basename "$f")
  ( cd "$d" && "$SL" -parse -nobuiltin -nocache -d uhdm "$b" >sl.log 2>&1 </dev/null )
  [ -f "$d/slpp_all/surelog.uhdm" ] || { echo "NOGOLD $f"; continue; }
  "$HP" "$d/slpp_all/surelog.uhdm" 2>/dev/null | norm > "$d/g.hp"
  for s in pris pat; do
    bin=$PRIS; [ $s = pat ] && bin=$PAT
    for v in plain elab; do
      fl=""; [ $v = elab ] && fl="--elabuhdm"
      ( cd "$d" && "$bin" $fl "$b" -o $s$v.uhdm >$s$v.log 2>&1 </dev/null )
      [ -f "$d/$s$v.uhdm" ] && "$HP" "$d/$s$v.uhdm" 2>/dev/null | norm > "$d/$s$v.hp" || : > "$d/$s$v.hp"
    done
  done
  echo "FILE $f"
  python3 "$(dirname "$0")/armscore69.py" "$d/g.hp" "$d/prisplain.hp" "$d/patplain.hp" "$d/priselab.hp" "$d/patelab.hp"
done 3< "$LIST"
