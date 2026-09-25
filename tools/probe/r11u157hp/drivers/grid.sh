#!/bin/bash
# r11u157: run a grid. args: <cases root> <out root> [binary]. Per case (every */dut.sv below the root, read on fd 3):
# g1.sh (golden + ours + uhdm-cmp + strict dumps), slpin.sh (golden decode under gdb), objtab(ours), hpsig.
# Asserts PROCESSED == LISTED. env: the pins (SURELOG UHDM_CMP), SCMP, GC.
set -u
D=$(cd "$(dirname "$0")" && pwd); R=$1; O=$2; BIN=${3:-$SLANG_UHDM}
mkdir -p "$O"; find "$R" -name dut.sv | sort > "$O/list.txt"
one() {
  c=$(dirname "$1"); rel=$(realpath --relative-to="$R" "$c"); o=$O/$rel; mkdir -p "$o"
  bash "$D/g1.sh" "$c" "$o" "$BIN" < /dev/null
  [ -s "$o/pin/objtab.txt" ] || bash "$D/slpin.sh" "$c" "$o/pin" > "$o/pin.txt" 2>&1 < /dev/null
  [ -s "$o/ours.uhdm" ] && /tmp/r11u157_bin/objtab "$o/ours.uhdm" > "$o/ours.objtab"
  [ -s "$o/pin/objtab.txt" ] && [ -s "$o/ours.objtab" ] && python3 "$D/hpsig.py" "$o/pin/objtab.txt" "$o/ours.objtab" --src "$c/dut.sv" > "$o/hpsig.txt"
  echo done >> "$O/processed.txt"
}
export -f one; export D R O BIN
rm -f "$O/processed.txt"
xargs -a "$O/list.txt" -P 3 -I{} bash -c 'one {}'
echo "LISTED $(wc -l < "$O/list.txt") PROCESSED $(wc -l < "$O/processed.txt")"
