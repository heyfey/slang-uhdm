#!/usr/bin/env bash
# r10uvm80repro/mv80.sh — ATTRIBUTE every byte-mover.  For each database that
# byteverify.sh named, it re-runs the census join on BOTH sides and prints the
# per-object delta, so a mover is never reported as a bare filename.
#
#   usage: mv80.sh <patched workdir root> <pristine workdir root>
#
# LHS is ALWAYS golden(Surelog), RHS is ALWAYS ours; the two arguments here are
# OURS-patched and OURS-pristine, and the golden each is measured against is the
# one named in that workdir's OWN cmds.txt.
set -u
A=${1:?patched workdir root}
B=${2:?pristine workdir root}
CEN=${R10UVM80CEN:-/tmp/r10uvm80cen}
n=0
while read -r p; do
  cmp -s "$A/$p" "$B/$p" && continue
  n=$((n+1))
  d=$(dirname "$p")
  echo "== MOVER $d"
  R10UVM80_LIST=1 "$CEN" "$B/$p" X | awk -F'\t' '$5=="1"{print $4"\t"$6"\t"$8}' | sort > /tmp/r10uvm80_mvb.$$
  R10UVM80_LIST=1 "$CEN" "$A/$p" X | awk -F'\t' '$5=="1"{print $4"\t"$6"\t"$8}' | sort > /tmp/r10uvm80_mva.$$
  echo "   automatic=1 objects: pristine=$(wc -l < /tmp/r10uvm80_mvb.$$) patched=$(wc -l < /tmp/r10uvm80_mva.$$)"
  diff /tmp/r10uvm80_mvb.$$ /tmp/r10uvm80_mva.$$ | grep -E '^[<>]' | sed 's/^/   /'
done < <(cd "$B" && find . -name slang.uhdm | sort)
rm -f /tmp/r10uvm80_mvb.$$ /tmp/r10uvm80_mva.$$
echo "-- attributed movers: $n"
