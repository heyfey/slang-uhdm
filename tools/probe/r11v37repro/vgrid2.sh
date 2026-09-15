#!/usr/bin/env bash
# v11u37 ADVERSARIAL GOLDEN GRID — faces r11u37's grid did NOT cover.
# Golden-only: every arm is compiled by the PINNED Surelog; the question is
# "which def-view / elab-view logic_nets does each holder carry".
#
# CONTROLS: arm `pc` (the corpus witness reduced) MUST mint work@c_pc.b;
#           arm `nc` names a missing source -> rc!=0, holders=0.
set -u
OUT=${1:-/tmp/v11u37_grid/out}
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -x "$SL" ] || { echo "FATAL: no surelog at $SL"; exit 3; }
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump at $DUMP"; exit 3; }
mkdir -p "$OUT" || exit 3
cd "$OUT" || exit 3
echo "grid outdir: $OUT"; echo "surelog:     $SL"; "$SL" --version 2>&1 | head -2

arms=0; nothing=0
run() {  # run <arm> <srcfile...>
  local n=$1; shift
  arms=$((arms+1))
  rm -rf "o_$n"
  "$SL" -parse -nobuiltin -nocache -sv "$@" -o "o_$n" > "$n.log" 2>&1
  local rc=$?
  "$DUMP" "o_$n/slpp_all/surelog.uhdm" > "$n.dump" 2>&1
  local h
  h=$(grep -c '^\\_module_inst\|^\\_interface_inst\|^\\_program\|^\\_class_defn' "$n.dump"; true)
  printf '%-6s rc=%-3s holders=%-3s nets: ' "$n" "$rc" "$h"
  if [ "$h" -eq 0 ]; then echo '!! ARM COMPILED NOTHING'; nothing=$((nothing+1)); return; fi
  grep -o 'logic_net: (work@[A-Za-z_0-9.]*), line:[0-9:]*' "$n.dump" \
    | sed 's/logic_net: //' | sort -u | tr '\n' ' '
  echo
}

echo '--- C. bounding the two over-mint faces ---'
# C1 body-level `localparam type` (the implementer's v3: golden MINTS).
cat > c1.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
module c_c1 (input logic i, output logic o);
  localparam type dt2 = d_t;
  dt2 w;
  assign o = i;
endmodule
module tb_c1; logic i,o; c_c1 t(.i(i),.o(o)); endmodule
EOF
run c1 c1.sv
# C2 `localparam type` in an UNNAMED generate-if block.
cat > c2.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
module c_c2 (input logic i, output logic o);
  if (1) begin
    localparam type dt2 = d_t;
    dt2 w;
  end
  assign o = i;
endmodule
module tb_c2; logic i,o; c_c2 t(.i(i),.o(o)); endmodule
EOF
run c2 c2.sv
# C3 `localparam type` in a generate FOR body.
cat > c3.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
module c_c3 (input logic i, output logic o);
  genvar gi;
  for (gi = 0; gi < 2; gi++) begin : g
    localparam type dt3 = d_t;
    dt3 w;
  end
  assign o = i;
endmodule
module tb_c3; logic i,o; c_c3 t(.i(i),.o(o)); endmodule
EOF
run c3 c3.sv
# C4 a NESTED module definition carrying the default.
cat > c4.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
module outer_c4 (input logic i, output logic o);
  module inner_c4 #(parameter type dtype = d_t) (input dtype a, output dtype b);
    assign b = a;
  endmodule
  d_t x, y;
  inner_c4 u (.a(x), .b(y));
  assign o = i;
endmodule
module tb_c4; logic i,o; outer_c4 t(.i(i),.o(o)); endmodule
EOF
run c4 c4.sv
# C5 the bound names a GENERATE-LOCAL signal of the instantiating module.
cat > c5.sv <<'EOF'
module c_c5 #(parameter type dtype = logic) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module m_c5 (input logic [7:0] a, output logic [12:0] o);
  if (1) begin : g
    logic [4:0] gb;
    c_c5 #(.dtype(logic [$bits(a) + $bits(gb) - 1:0])) u (.d_i(o), .d_o(o));
  end
endmodule
module tb_c5; logic [12:0] o; m_c5 t(.a(8'd0),.o(o)); endmodule
EOF
run c5 c5.sv
# C6 the CHILD declares a PARAMETER of the bound's name.
cat > c6.sv <<'EOF'
module c_c6 #(parameter type dtype = logic, parameter int b = 3) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module m_c6 (input logic [7:0] a, input logic [4:0] b, output logic [12:0] o);
  c_c6 #(.dtype(logic [$bits(a) + $bits(b) - 1:0])) u (.d_i(o), .d_o(o));
endmodule
module tb_c6; logic [12:0] o; m_c6 t(.a(8'd0),.b(5'd0),.o(o)); endmodule
EOF
run c6 c6.sv
# C7 the CHILD declares a TYPEDEF of the bound's name.
cat > c7.sv <<'EOF'
module c_c7 #(parameter type dtype = logic) (input dtype d_i, output dtype d_o);
  typedef logic [1:0] b;
  assign d_o = d_i;
endmodule
module m_c7 (input logic [7:0] a, input logic [4:0] b, output logic [12:0] o);
  c_c7 #(.dtype(logic [$bits(a) + $bits(b) - 1:0])) u (.d_i(o), .d_o(o));
endmodule
module tb_c7; logic [12:0] o; m_c7 t(.a(8'd0),.b(5'd0),.o(o)); endmodule
EOF
run c7 c7.sv
# C8 ORDERED override with a CONSTANT range (the corpus's ordered shape).
cat > c8.sv <<'EOF'
module c_c8 #(parameter type dtype = logic) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module m_c8 (input logic [7:0] a, output logic [31:0] o);
  c_c8 #(logic [31:0]) u (.d_i(o), .d_o(o));
endmodule
module tb_c8; logic [31:0] o; m_c8 t(.a(8'd0),.o(o)); endmodule
EOF
run c8 c8.sv
# C9 a type-parameter default that is a bare name, in a module also carrying
#    an ORDERED value override of a child (mixed shapes in one design).
cat > c9.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
module k_c9 #(parameter int P = 1) (input logic [P-1:0] x, output logic [P-1:0] y);
  assign y = x;
endmodule
module c_c9 #(parameter type dtype = d_t) (input dtype d_i, output dtype d_o);
  logic [3:0] q, r;
  k_c9 #(4) u (.x(q), .y(r));
  assign d_o = d_i;
endmodule
module tb_c9; d_t x,y; c_c9 t(.d_i(x),.d_o(y)); endmodule
EOF
run c9 c9.sv

echo '--- NEGATIVE CONTROL (2) ---'
run nc2 no_such_file_v11u37_2.sv
echo "-- arms=$arms  compiled-nothing=$nothing"
