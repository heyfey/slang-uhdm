#!/usr/bin/env bash
# v91 verifier byteverify: PATH-SET assertion first, then md5 of every database.
set -u
A=${1:?patched wd}; B=${2:?pristine wd}; LBL=${3:?label}
cd "$B" && find . -name slang.uhdm | sort > /tmp/v91_paths_pris_$LBL.txt
cd "$A" && find . -name slang.uhdm | sort > /tmp/v91_paths_pat_$LBL.txt
if cmp -s /tmp/v91_paths_pris_$LBL.txt /tmp/v91_paths_pat_$LBL.txt; then
  echo "$LBL PATH_SETS_IDENTICAL ($(wc -l < /tmp/v91_paths_pris_$LBL.txt) paths)"
else
  echo "$LBL PATH_SETS_DIFFER"; diff /tmp/v91_paths_pris_$LBL.txt /tmp/v91_paths_pat_$LBL.txt | head
fi
n=0; mv=0
while IFS= read -r p; do
  n=$((n+1))
  ha=$(md5sum "$A/$p" | cut -c1-12); hb=$(md5sum "$B/$p" | cut -c1-12)
  [ "$ha" = "$hb" ] || { echo "  MOVER ${p#./}  $hb -> $ha"; mv=$((mv+1)); }
done < /tmp/v91_paths_pris_$LBL.txt
echo "---- $LBL MOVERS $mv / $n"
