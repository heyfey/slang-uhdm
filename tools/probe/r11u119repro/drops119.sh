#!/usr/bin/env bash
# r11u119 drops: (1) R11U119_OFF=1 on the law binary must write the PRISTINE
# bytes on every grid arm (cmp of the .uhdm, same cwd, same output path);
# (2) each switch alone reverts only its own cells: per switch, the number of
# grid arms whose database differs from the full-law database.
#   drops119.sh <pristine bin> <law bin> <grid root> <scratch>
set -u
P=$1; L=$2; root=$(realpath "$3"); w=$4; mkdir -p "$w"
exec 3< <(cd "$root" && find . -name dut.sv | sort)
arms=(); while read -r a <&3; do arms+=("$(dirname "$a")"); done
run() { # bin env-assignment out
  ( cd "$root/$4" && env $2 "$1" dut.sv --single-unit --nobuiltin -o "$3" </dev/null >/dev/null 2>&1 ); }
same=0; diffc=0; self=0
for a in "${arms[@]}"; do
  k=${a#./}; k=${k//\//__}
  run "$P" "X=1" "$w/$k.p.uhdm" "$a"; run "$P" "X=1" "$w/$k.p2.uhdm" "$a"
  run "$L" "R11U119_OFF=1" "$w/$k.off.uhdm" "$a"; run "$L" "X=1" "$w/$k.law.uhdm" "$a"
  cmp -s "$w/$k.p.uhdm" "$w/$k.p2.uhdm" && self=$((self+1))
  if cmp -s "$w/$k.p.uhdm" "$w/$k.off.uhdm"; then same=$((same+1)); else diffc=$((diffc+1)); echo "OFF-DIFFERS $k"; fi
done
echo "ARMS=${#arms[@]} PRISTINE-SELF-STABLE=$self OFF==PRISTINE=$same OFF!=PRISTINE=$diffc"
for sw in R11U119_SCOPEDSPAN_OFF R11U119_ALIASGATE_OFF R11U119_IMPLFILE_OFF R11U119_NUMLIT_OFF R11U119_REALATTR_OFF; do
  moved=(); 
  for a in "${arms[@]}"; do
    k=${a#./}; k=${k//\//__}
    run "$L" "$sw=1" "$w/$k.$sw.uhdm" "$a"
    cmp -s "$w/$k.law.uhdm" "$w/$k.$sw.uhdm" || moved+=("$k")
  done
  echo "$sw reverts ${#moved[@]}: ${moved[*]}"
done
