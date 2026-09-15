#!/bin/bash
# v11u43 VERIFIER census POSITIVE CONTROL: a source that MUST claim and one
# that MUST NOT, through the same neutral binary + trace the census uses.
BIN=${BIN:?}
T=$(mktemp -d /tmp/v11u43_ctl_XXXX)
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
cat > "$T/none.sv" <<'SV'
module ctlnone (input logic clk);
  logic [7:0] x;
  assign x = 8'd0;
endmodule
SV
for a in hit miss none; do
  e=$(cd "$T" && R11U43_OFF=1 R11U43_CELLDBG=1 "$BIN" $a.sv --single-unit -o "$T/$a.uhdm" 2>&1 >/dev/null)
  c1=$(printf '%s' "$e" | grep -c 'R11U43CELL .*claim=1'); c0=$(printf '%s' "$e" | grep -c 'R11U43CELL '); true
  printf 'CONTROL %-5s trace_lines=%s claim1_lines=%s\n' "$a" "$c0" "$c1"
done
rm -rf "$T"
