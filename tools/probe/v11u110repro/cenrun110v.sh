#!/bin/bash
# cenrun110v.sh <sweep-workdir-root> <out-dir> — law-1 shape census (cen110v) over every
# slang.uhdm of a verify_golden.py workdir: golden located via cmds.txt (cache hit) or the
# workdir's slpp_*/surelog.uhdm.  Per DB: golden-vs-golden calibration NE count (must be 0),
# then golden-vs-ours per-cell EQ/NE of every elaborated port whose GOLDEN typedef is a
# packed_array_typespec parented at a type_parameter with a NAMED element ref.
# Build: g++ -O1 -std=c++17 cen110v.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cen110v
ROOT=${1:?root}; OUT=${2:?out}; CEN=${CEN:-$(dirname "$0")/cen110v}
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
mkdir -p "$OUT"; : > "$OUT/sum.txt"; : > "$OUT/cells.txt"
while read -r f <&3; do
  d=$(dirname "$f"); rel=${d#$ROOT/}
  g=$(sed -n 's/.*cache hit \(.*\))/\1/p' "$d/cmds.txt" 2>/dev/null)
  if [ -n "$g" ]; then g=$g/golden.uhdm; else g=$(ls "$d"/slpp_*/surelog.uhdm 2>/dev/null | head -1); fi
  [ -f "$g" ] || { echo "$rel NOGOLD" >> "$OUT/sum.txt"; continue; }
  cc=$(timeout 600 "$CEN" "$g" "$g" </dev/null 2>&1 | grep -c ' NE$'; true)
  r=$(timeout 600 "$CEN" "$g" "$f" </dev/null 2>&1)
  echo "$rel calibNE=$cc $(grep TOTAL <<<"$r") ne=$(grep -c ' NE$' <<<"$r"; true) eq=$(grep -c ' EQ$' <<<"$r"; true)" >> "$OUT/sum.txt"
  grep GSHAPE <<<"$r" | sed "s#^#$rel #" >> "$OUT/cells.txt"
done 3< <(find "$ROOT" -name slang.uhdm | sort)
echo "PROCESSED=$(grep -c . "$OUT/sum.txt") LISTED=$(find "$ROOT" -name slang.uhdm | wc -l)"
