#!/bin/bash
# vsd10 BOUNDARY re-run.  Uses the verifier arm, which runs golden AND BOTH
# binaries in ONE scratch dir — so uhdm-dump's embedded workdir paths are the
# SAME on both sides and no normalisation is needed (the trap that made the
# implementer's first ct10bound run report all 44 cells MOVED).
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
DIRS=${*:-"qgrid4 grid6 grid7 grid7v grid8 vgrid8 grid9 grid10 vgrid10"}
cells=0; ident=0; moved=0; bad=0
for gd in $DIRS; do
  [ -d "$HERE/$gd" ] || { echo "FATAL: no grid dir $gd"; exit 3; }
  n=$(ls "$HERE/$gd"/*.sv 2>/dev/null | wc -l)
  [ "$n" -gt 0 ] || { echo "FATAL: $gd has no cells"; exit 4; }
  echo "======== $gd ($n cells)"
  for c in $(cd "$HERE/$gd" && ls *.sv); do
    b=${c%.sv}; cells=$((cells+1))
    D=/tmp/vsd10_bnd_${gd}_$b
    out=$("$HERE/vsd10arm.sh" "$HERE/$gd/$c" "$D" 2>&1)
    if [ ! -f $D/pris.dump ] || [ ! -f $D/pat.dump ]; then
      echo "  $gd/$b  NO_DUMP <- CANNOT SCORE"; echo "$out" | sed 's/^/      /'; bad=$((bad+1)); continue
    fi
    if cmp -s $D/pris.dump $D/pat.dump; then
      ident=$((ident+1)); echo "  $gd/$b  IDENTICAL  $(echo "$out" | grep -o '\[pat\].*')"
    else
      moved=$((moved+1)); echo "  $gd/$b  MOVED"
      echo "$out" | grep -E '\[pris\]|\[pat\]' | sed 's/^/    /'
      python3 "$HERE/vsd10kt.py" $D
      diff -u $D/pris.dump $D/pat.dump | grep -E '^[-+]' | grep -vE '^(---|\+\+\+) ' | sed 's/^/      /'
    fi
  done
done
echo "[S] cells=$cells IDENTICAL=$ident MOVED=$moved UNSCORABLE=$bad"
