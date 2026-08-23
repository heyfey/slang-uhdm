#!/usr/bin/env bash
# r10uvm104 census CALIBRATION — golden-vs-golden.  Surelog is run TWICE on the
# same arm into two different output directories and the two dumps are compared
# with the same key the census uses.  A census whose golden-vs-golden score is
# not 0 measures the instrument, not the model.
set -u
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
WD=${CALWD:?}
rm -rf "$WD"; mkdir -p "$WD" || exit 9
printf '%-22s %-5s %s\n' ARM VIEW GOLDEN_VS_GOLDEN_CELLS
for src in "$@"; do
  b=$(basename "$src")
  for view in def elab; do
    opt=(); [ "$view" = elab ] && opt=(-elabuhdm)
    for r in r1 r2; do
      d=$WD/$b.$view.$r; mkdir -p "$d"; cp "$src" "$d/"
      ( cd "$d" && "$SURELOG" -parse -sverilog "${opt[@]}" "$b" -mt 0 -mp 0 -o out >sl.log 2>&1 </dev/null )
      g=$(find "$d/out" -name '*.uhdm' | head -1)
      "$DUMP" "$g" 2>/dev/null | grep -E '\|(STRING:|vpiDecompile:)' | sort > "$WD/$b.$view.$r.txt"
    done
    n=$(comm -3 "$WD/$b.$view.r1.txt" "$WD/$b.$view.r2.txt" | wc -l)
    printf '%-22s %-5s %s\n' "$b" "$view" "$n"
  done
done
