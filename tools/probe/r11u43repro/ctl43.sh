#!/bin/bash
# r11u43 — THE CENSUS POSITIVE CONTROL, spelled out.
#
# A census zero needs a positive control.  This one runs the SAME neutral
# binary + trace the corpus census used against (a) a source that MUST claim
# and (b) a source that MUST NOT, so a silent scan is distinguishable from a
# true zero.
BIN=${BIN:?set BIN}
T=$(mktemp -d /tmp/r11u43_ctl_XXXX)
cat > "$T/hit.sv" <<'SV'
module ctlhit (input logic clk);
  typedef struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; } st_t;
  st_t [2:0] x;
  assign x = '0;
endmodule
SV
cat > "$T/miss.sv" <<'SV'
module ctlmiss (input logic clk);
  typedef struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; } st_t;
  st_t x;
  assign x = '0;
endmodule
SV
for a in hit miss; do
  out=$(cd "$T" && R11U43_OFF=1 R11U43_CELLDBG=1 "$BIN" $a.sv --single-unit \
        -o "$T/$a.uhdm" 2>&1 >/dev/null | grep -c 'R11U43CELL .*claim=1')
  printf 'CONTROL %s claim1_lines=%s\n' "$a" "$out"
done
rm -rf "$T"
