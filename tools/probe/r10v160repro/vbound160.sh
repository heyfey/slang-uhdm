#!/usr/bin/env bash
# r10v160repro/vbound160.sh — THE VERIFIER'S WIDE BOUNDARY.  Every committed
# probe arm (.sv, SUBDIRECTORIES INCLUDED), both views, both binaries; the two
# OUR-side databases are byte-compared.  An arm whose two databases differ is a
# MOVED arm and is then judged against golden separately.
#   LISTED and PROCESSED are both asserted (a list swallowed by a child reads
#   as green); the file list arrives on fd 3 and every child gets </dev/null;
#   scratch is keyed on the RELATIVE path (three arms are named dut.sv); every
#   cell records its own rc (rc=139 must never read as a result).
# MEASUREMENT ONLY.
#   vbound160.sh <repo root> <bin A> <bin B> <workdir>
set -u
R=$1; A=$2; B=$3; W=$4
mkdir -p "$W"; : > "$W/moved.txt"; : > "$W/rcdiff.txt"; : > "$W/cmds.txt"
find "$R/tools/probe" -name '*.sv' | sed "s#^$R/##" | sort > "$W/list.txt"
LISTED=$(wc -l < "$W/list.txt"); PROC=0
exec 3< "$W/list.txt"
while read -r rel <&3; do
  PROC=$((PROC+1))
  key=$(echo "$rel" | tr '/' '_')
  d="$W/s/$key"; mkdir -p "$d"
  for v in def elab; do
    EF=""; [ "$v" = elab ] && EF="--elabuhdm"
    "$A" "$R/$rel" $EF -o "$d/a_$v.uhdm" > /dev/null 2>&1 </dev/null; ra=$?
    "$B" "$R/$rel" $EF -o "$d/b_$v.uhdm" > /dev/null 2>&1 </dev/null; rb=$?
    echo "$rel $v rc_a=$ra rc_b=$rb" >> "$W/cmds.txt"
    [ "$ra" != "$rb" ] && echo "RCDIFF $rel $v a=$ra b=$rb" >> "$W/rcdiff.txt"
    if [ -f "$d/a_$v.uhdm" ] && [ -f "$d/b_$v.uhdm" ]; then
      ha=$(md5sum < "$d/a_$v.uhdm" | cut -c1-12); hb=$(md5sum < "$d/b_$v.uhdm" | cut -c1-12)
      [ "$ha" != "$hb" ] && echo "MOVED $rel $v a=$ha b=$hb" >> "$W/moved.txt"
    elif [ -f "$d/a_$v.uhdm" ] || [ -f "$d/b_$v.uhdm" ]; then
      echo "MOVED $rel $v ONE-SIDED" >> "$W/moved.txt"
    fi
  done
  rm -f "$d"/*.uhdm
done
exec 3<&-
echo "LISTED=$LISTED PROCESSED=$PROC"
echo "MOVED_ARMS=$(cut -d' ' -f2 "$W/moved.txt" | sort -u | wc -l)  MOVED_CELLS=$(wc -l < "$W/moved.txt")  RC_DIFFS=$(wc -l < "$W/rcdiff.txt")"
