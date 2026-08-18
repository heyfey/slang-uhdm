#!/usr/bin/env bash
# r10v69 - score every boundary-differing FILE against a REBUILT Surelog golden,
# judge-faithfully and with a NO-SPAN payload.  usage: vscore.sh <list> <outdir>
set -u
SL=$HOME/git-repos/Surelog/build/bin/surelog
HP=${HPNAME:?set HPNAME to the built hpname69}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
PAT=${PATCHED_BIN:?}; PRIS=${PRISTINE_BIN:?}
LIST=${1:?}; OUT=${2:?}
mkdir -p "$OUT"
while read -r f <&3; do
  key=$(echo "${f#/}" | tr '/' '_'); key=${key%.sv}; key=${key%.v}
  d="$OUT/$key"; mkdir -p "$d"; cp "$f" "$d/" || continue
  b=$(basename "$f")
  ( cd "$d" && "$SL" -parse -nobuiltin -nocache -d uhdm "$b" >sl.log 2>&1 </dev/null )
  if [ -f "$d/slpp_all/surelog.uhdm" ]; then
    "$HP" "$d/slpp_all/surelog.uhdm" 2>/dev/null > "$d/g.hp"
  else
    echo "NOGOLD $f"; : > "$d/g.hp"
  fi
  for s in pris pat; do
    bin=$PRIS; [ $s = pat ] && bin=$PAT
    for v in plain elab; do
      fl=""; [ $v = elab ] && fl="--elabuhdm"
      ( cd "$d" && "$bin" $fl "$b" -o $s$v.uhdm >$s$v.log 2>&1 </dev/null )
      echo "RC $? $s $v $f" >> "$OUT/rc.txt"
      if [ -f "$d/$s$v.uhdm" ]; then
        "$HP" "$d/$s$v.uhdm" 2>/dev/null > "$d/$s$v.hp"
        "$DUMP" "$d/$s$v.uhdm" 2>/dev/null | sed '1d' | sed "s#$d#WD#g" > "$d/$s$v.dump"
      else
        : > "$d/$s$v.hp"; : > "$d/$s$v.dump"
      fi
    done
  done
  echo "FILE $f"
  for v in plain elab; do
    python3 "$(dirname "$0")"/vscore69v.py "$d/g.hp" "$d/pris$v.hp" "$d/pat$v.hp" "   $v"
    nl=$(diff "$d/pris$v.dump" "$d/pat$v.dump" | grep -c '^[<>]'; true)
    nb=$(diff <(sort "$d/pris$v.dump") <(sort "$d/pat$v.dump") | grep -c '^[<>]'; true)
    echo "    $v dump-diff raw=$nl order-blind=$nb"
  done
done 3< "$LIST"
