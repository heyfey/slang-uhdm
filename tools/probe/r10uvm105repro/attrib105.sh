#!/usr/bin/env bash
# r10uvm105repro/attrib105.sh — ORDER-BLIND ATTRIBUTION of one byte mover.
# MEASUREMENT ONLY.
#
#   attrib105.sh <pristine .uhdm> <patched .uhdm> <outdir>
#
# Scoreboard/default is a ~50/50 COIN per invocation (RESUME §9), so a mover's
# changed lines may only be attributed ORDER-BLIND: both dumps are
# path-normalised (dump paths embed the workdir), have their object ids and
# their `, id:NNN` suffixes stripped, and are SORTED before the diff.  What
# survives is what actually changed, independent of the coin and of arena order.
set -u
P=${1:?pristine db}; Q=${2:?patched db}; O=${3:?outdir}
mkdir -p "$O"
norm() {
  uhdm-dump "$1" 2>&1 \
    | sed -e '1s#^[^:]*\.uhdm:#<DB>:#' \
          -e 's#, id:[0-9]\+##g' \
          -e 's#id:[0-9]\+##g' \
          -e 's#/tmp/[A-Za-z0-9_.-]*/#<WD>/#g' \
    | LC_ALL=C sort
}
norm "$P" > "$O/p.sorted"
norm "$Q" > "$O/q.sorted"
diff "$O/p.sorted" "$O/q.sorted" > "$O/diff.txt"
echo "changed lines: $(grep -c '^[<>]' "$O/diff.txt" || true)"
echo "-- source lines named by the changed lines (line:NN):"
grep '^[<>]' "$O/diff.txt" | grep -o 'line:[0-9]*' | sort -u -t: -k2 -n | tr '\n' ' '; echo
echo "-- kinds:"
grep '^[<>]' "$O/diff.txt" | sed 's/^\(.\) *\\\?_\?\([a-z_]*\):.*/\1 \2/' | sort | uniq -c | sort -rn | head -12
