#!/bin/bash
# probe_ours.sh <out dir>: export every tests/probe/**/dut.sv with the frozen binary (check_probe.py SU_ARGS),
# 3 at a time; rc per case in <out>/rc.tsv. The list is read on fd 3; children read /dev/null.
OUT=$1; B=${SLANG_UHDM:-/tmp/r11u129_bin/slang-uhdm}; P=$(realpath "$(dirname "$0")/../../../../tests/probe")
cd "$P"; : > "$OUT/rc.tsv"
one() { rel=$1; o="$OUT/${rel//\//__}.uhdm"; rm -f "$o"; (cd "$rel" && timeout 120 "$B" dut.sv --single-unit --nobuiltin -o "$o" >/dev/null 2>&1 </dev/null); echo -e "$rel\t$?" >> "$OUT/rc.tsv"; }
export -f one; export OUT B
find . -name dut.sv | sed 's|^\./||; s|/dut.sv$||' | sort > "$OUT/list.txt"
xargs -a "$OUT/list.txt" -P 3 -I{} bash -c 'one "$@"' _ {}
echo "listed $(wc -l < "$OUT/list.txt") processed $(wc -l < "$OUT/rc.tsv")"
