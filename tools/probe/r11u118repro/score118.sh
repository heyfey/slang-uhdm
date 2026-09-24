#!/usr/bin/env bash
# score118.sh <grid outroot> — per arm: golden (gds) pkg-qualified select cells
# (part_select/indexed_part_select/var_select with `::` in the name), and how many of them
# ours_ds reproduces EXACTLY (kind, span, VpiFile, name, defname, fullname).
R=$1; C=${CONST:-/tmp/r11u118_const}
for d in $(find "$R" -maxdepth 2 -name gds.uhdm -printf '%h\n' | sort); do
  g=$($C $d/gds.uhdm | grep -E "^(part_select|indexed_part_select|var_select)#" | grep "name='[^']*::" | sed -E 's/#[0-9]+//; s/ dec=.*//' | sort)
  o=$($C $d/ours_ds.uhdm | grep -E "^(part_select|indexed_part_select|var_select)#" | sed -E 's/#[0-9]+//; s/ dec=.*//' | sort)
  ng=$(printf '%s\n' "$g" | grep -c .); nm=$(comm -12 <(printf '%s\n' "$g" | grep .) <(printf '%s\n' "$o" | grep .) | wc -l)
  echo "$(basename $d) golden_cells=$ng exact=$nm"
done
