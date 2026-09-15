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

# ---------- POSITIVE CONTROL: the corpus witness reduced ----------
cat > pc.sv <<'EOF'
module c_pc #(parameter type dtype = logic) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module m_pc #(parameter int W = 5) (input logic [7:0] a, input logic [W-1:0] b, output logic [12:0] o);
  c_pc #(.dtype(logic [$bits(a) + $bits(b) - 1:0])) u (.d_i(o), .d_o(o));
endmodule
module tb_pc; logic [12:0] o; m_pc #(.W(5)) t(.a(8'd0),.b(5'd0),.o(o)); endmodule
EOF
run pc pc.sv                       # MUST mint work@c_pc.b

echo '--- A. KEY-2 shapes the implementer did not test ---'
# A1 ORDERED (positional) type-parameter override.
cat > a1.sv <<'EOF'
module c_a1 #(parameter type dtype = logic) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module m_a1 (input logic [7:0] a, input logic [4:0] b, output logic [12:0] o);
  c_a1 #(logic [$bits(a) + $bits(b) - 1:0]) u (.d_i(o), .d_o(o));
endmodule
module tb_a1; logic [12:0] o; m_a1 t(.a(8'd0),.b(5'd0),.o(o)); endmodule
EOF
run a1 a1.sv
# A2 instantiation inside a GENERATE block.
cat > a2.sv <<'EOF'
module c_a2 #(parameter type dtype = logic) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module m_a2 (input logic [7:0] a, input logic [4:0] b, output logic [12:0] o);
  genvar gi;
  generate for (gi = 0; gi < 2; gi++) begin : g
    c_a2 #(.dtype(logic [$bits(a) + $bits(b) - 1:0])) u (.d_i(o), .d_o(o));
  end endgenerate
endmodule
module tb_a2; logic [12:0] o; m_a2 t(.a(8'd0),.b(5'd0),.o(o)); endmodule
EOF
run a2 a2.sv
# A3 the SAME child instantiated from TWO different parents, different names.
cat > a3.sv <<'EOF'
module c_a3 #(parameter type dtype = logic) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module p1_a3 (input logic [7:0] a, input logic [4:0] b, output logic [12:0] o);
  c_a3 #(.dtype(logic [$bits(a) + $bits(b) - 1:0])) u (.d_i(o), .d_o(o));
endmodule
module p2_a3 (input logic [7:0] c, input logic [4:0] d, output logic [12:0] o);
  c_a3 #(.dtype(logic [$bits(c) + $bits(d) - 1:0])) u (.d_i(o), .d_o(o));
endmodule
module tb_a3; logic [12:0] o; p1_a3 t1(.a(8'd0),.b(5'd0),.o(o)); p2_a3 t2(.c(8'd0),.d(5'd0),.o(o)); endmodule
EOF
run a3 a3.sv
# A4 the same child instantiated TWICE in the SAME parent, different names.
cat > a4.sv <<'EOF'
module c_a4 #(parameter type dtype = logic) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module m_a4 (input logic [7:0] a, input logic [4:0] b, input logic [2:0] c, output logic [12:0] o);
  c_a4 #(.dtype(logic [$bits(a) + $bits(b) - 1:0])) u1 (.d_i(o), .d_o(o));
  c_a4 #(.dtype(logic [$bits(a) + $bits(c) - 1:0])) u2 (.d_i(o), .d_o(o));
endmodule
module tb_a4; logic [12:0] o; m_a4 t(.a(8'd0),.b(5'd0),.c(3'd0),.o(o)); endmodule
EOF
run a4 a4.sv
# A5 a TWO-DIMENSIONAL ranged actual.
cat > a5.sv <<'EOF'
module c_a5 #(parameter type dtype = logic) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module m_a5 (input logic [7:0] a, input logic [4:0] b, output logic o);
  c_a5 #(.dtype(logic [$bits(a) + $bits(b) - 1:0][$bits(a) + $bits(b) - 1:0])) u (.d_i(o), .d_o(o));
endmodule
module tb_a5; logic o; m_a5 t(.a(8'd0),.b(5'd0),.o(o)); endmodule
EOF
run a5 a5.sv
# A6 a NAMED type with a range as the actual (patch skips: not IntegerTypeSyntax).
cat > a6.sv <<'EOF'
typedef logic [1:0] n_t;
module c_a6 #(parameter type dtype = logic) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module m_a6 (input logic [7:0] a, input logic [4:0] b, output logic [12:0] o);
  c_a6 #(.dtype(n_t [$bits(a) + $bits(b) - 1:0])) u (.d_i(o), .d_o(o));
endmodule
module tb_a6; logic [12:0] o; m_a6 t(.a(8'd0),.b(5'd0),.o(o)); endmodule
EOF
run a6 a6.sv
# A7 a packed STRUCT actual carrying names in a member range.
cat > a7.sv <<'EOF'
module c_a7 #(parameter type dtype = logic) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module m_a7 (input logic [7:0] a, input logic [4:0] b, output logic [12:0] o);
  c_a7 #(.dtype(struct packed { logic [$bits(a) + $bits(b) - 1:0] f; })) u (.d_i(o), .d_o(o));
endmodule
module tb_a7; logic [12:0] o; m_a7 t(.a(8'd0),.b(5'd0),.o(o)); endmodule
EOF
run a7 a7.sv
# A8 a FUNCTION call in the bound.
cat > a8.sv <<'EOF'
module c_a8 #(parameter type dtype = logic) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module m_a8 (input logic [7:0] a, input logic [4:0] b, output logic [12:0] o);
  function automatic int f(input int x); return x; endfunction
  c_a8 #(.dtype(logic [$bits(a) + f($bits(b)) - 1:0])) u (.d_i(o), .d_o(o));
endmodule
module tb_a8; logic [12:0] o; m_a8 t(.a(8'd0),.b(5'd0),.o(o)); endmodule
EOF
run a8 a8.sv
# A9 a name reached through an INTERFACE port / hierarchical reference.
cat > a9.sv <<'EOF'
interface if_a9; logic [3:0] sig; endinterface
module c_a9 #(parameter type dtype = logic) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module m_a9 (if_a9 ifp, input logic [7:0] a, output logic [12:0] o);
  c_a9 #(.dtype(logic [$bits(a) + $bits(ifp.sig) - 1:0])) u (.d_i(o), .d_o(o));
endmodule
module tb_a9; logic [12:0] o; if_a9 ii(); m_a9 t(.ifp(ii),.a(8'd0),.o(o)); endmodule
EOF
run a9 a9.sv
# A10 a STRUCT MEMBER access in the bound.
cat > a10.sv <<'EOF'
typedef struct packed { logic [3:0] f; } s_t;
module c_a10 #(parameter type dtype = logic) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module m_a10 (input logic [7:0] a, output logic [12:0] o);
  s_t sv;
  c_a10 #(.dtype(logic [$bits(a) + $bits(sv.f) - 1:0])) u (.d_i(o), .d_o(o));
endmodule
module tb_a10; logic [12:0] o; m_a10 t(.a(8'd0),.o(o)); endmodule
EOF
run a10 a10.sv
# A11 a LOCAL VARIABLE (not a port) in the bound.
cat > a11.sv <<'EOF'
module c_a11 #(parameter type dtype = logic) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module m_a11 (input logic [7:0] a, output logic [12:0] o);
  logic [5:0] vv;
  c_a11 #(.dtype(logic [$bits(a) + $bits(vv) - 1:0])) u (.d_i(o), .d_o(o));
endmodule
module tb_a11; logic [12:0] o; m_a11 t(.a(8'd0),.o(o)); endmodule
EOF
run a11 a11.sv
# A12 GENVAR in the bound (inside a generate).
cat > a12.sv <<'EOF'
module c_a12 #(parameter type dtype = logic) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module m_a12 (input logic [7:0] a, output logic [12:0] o);
  genvar gi;
  generate for (gi = 1; gi < 3; gi++) begin : g
    c_a12 #(.dtype(logic [$bits(a) + gi - 1:0])) u (.d_i(o), .d_o(o));
  end endgenerate
endmodule
module tb_a12; logic [12:0] o; m_a12 t(.a(8'd0),.o(o)); endmodule
EOF
run a12 a12.sv
# A13 the child ALSO declares nets: where does the phantom land in the vector?
cat > a13.sv <<'EOF'
module c_a13 #(parameter type dtype = logic) (input dtype d_i, output dtype d_o);
  logic n1; logic n2;
  assign d_o = d_i;
endmodule
module m_a13 (input logic [7:0] a, input logic [4:0] b, output logic [12:0] o);
  c_a13 #(.dtype(logic [$bits(a) + $bits(b) - 1:0])) u (.d_i(o), .d_o(o));
endmodule
module tb_a13; logic [12:0] o; m_a13 t(.a(8'd0),.b(5'd0),.o(o)); endmodule
EOF
run a13 a13.sv

echo '--- B. KEY-1 shapes the implementer did not test ---'
# B1 the default names a $unit CLASS.
cat > b1.sv <<'EOF'
class k_b1; int v; endclass
module c_b1 #(parameter type dtype = k_b1) (input logic i, output logic o);
  assign o = i;
endmodule
module tb_b1; logic i,o; c_b1 t(.i(i),.o(o)); endmodule
EOF
run b1 b1.sv
# B2 the default names a $unit ENUM typedef.
cat > b2.sv <<'EOF'
typedef enum logic [1:0] { E0, E1 } e_b2;
module c_b2 #(parameter type dtype = e_b2) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module tb_b2; e_b2 x,y; c_b2 t(.d_i(x),.d_o(y)); endmodule
EOF
run b2 b2.sv
# B3 the default names a SAME-HEADER localparam type (the ariane acc_dispatcher face).
cat > b3.sv <<'EOF'
module c_b3 #(
    localparam type base_t = struct packed { logic [3:0] f; },
    parameter type dtype = base_t
) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module tb_b3; logic [3:0] x,y; c_b3 t(.d_i(x),.d_o(y)); endmodule
EOF
run b3 b3.sv
# B4 the default names a SAME-HEADER type PARAMETER (type_param_packed_dim face).
cat > b4.sv <<'EOF'
module c_b4 #(parameter type id_t = logic, parameter type resp_id_t = id_t)
  (input resp_id_t d_i, output resp_id_t d_o);
  assign d_o = d_i;
endmodule
module tb_b4; logic x,y; c_b4 t(.d_i(x),.d_o(y)); endmodule
EOF
run b4 b4.sv
# B5 the module declares a PORT of the name.
cat > b5.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
module c_b5 #(parameter type dtype = d_t) (input logic d_t, input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module tb_b5; d_t x,y; logic z; c_b5 t(.d_t(z),.d_i(x),.d_o(y)); endmodule
EOF
run b5 b5.sv
# B6 the module declares a FUNCTION of the name (not a signal).
cat > b6.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
module c_b6 #(parameter type dtype = d_t) (input dtype d_i, output dtype d_o);
  function automatic int d_t(input int x); return x; endfunction
  assign d_o = d_i;
endmodule
module tb_b6; d_t x,y; c_b6 t(.d_i(x),.d_o(y)); endmodule
EOF
run b6 b6.sv
# B7 the module declares a LOCALPARAM (value) of the name.
cat > b7.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
module c_b7 #(parameter type dtype = d_t) (input dtype d_i, output dtype d_o);
  localparam int d_t = 3;
  assign d_o = d_i;
endmodule
module tb_b7; d_t x,y; c_b7 t(.d_i(x),.d_o(y)); endmodule
EOF
run b7 b7.sv
# B8 a `localparam type` inside a GENERATE block.
cat > b8.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
module c_b8 (input logic i, output logic o);
  generate if (1) begin : g
    localparam type dt2 = d_t;
    dt2 w;
  end endgenerate
  assign o = i;
endmodule
module tb_b8; logic i,o; c_b8 t(.i(i),.o(o)); endmodule
EOF
run b8 b8.sv
# B9 TWO modules sharing one $unit typedef default: does each def get its own?
cat > b9.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
module c1_b9 #(parameter type dtype = d_t) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module c2_b9 #(parameter type dtype = d_t) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module tb_b9; d_t x,y; c1_b9 t1(.d_i(x),.d_o(y)); c2_b9 t2(.d_i(x),.d_o(y)); endmodule
EOF
run b9 b9.sv
# B10 the $unit typedef is declared AFTER the module in the same file.
cat > b10.sv <<'EOF'
module c_b10 #(parameter type dtype = d_t) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
typedef struct packed { logic [3:0] op; } d_t;
module tb_b10; d_t x,y; c_b10 t(.d_i(x),.d_o(y)); endmodule
EOF
run b10 b10.sv
# B11 an EXPLICIT (non-wildcard) import in the module itself.
cat > b11.sv <<'EOF'
package pk11; typedef struct packed { logic [3:0] op; } k_t; endpackage
module c_b11 #(parameter type dtype = k_t) (input dtype d_i, output dtype d_o);
  import pk11::k_t;
  assign d_o = d_i;
endmodule
module tb_b11; import pk11::*; k_t x,y; c_b11 t(.d_i(x),.d_o(y)); endmodule
EOF
run b11 b11.sv
# B12 the import is on the module HEADER (before the parameter list).
cat > b12.sv <<'EOF'
package pk12; typedef struct packed { logic [3:0] op; } k_t; endpackage
module c_b12 import pk12::*; #(parameter type dtype = k_t) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module tb_b12; import pk12::*; k_t x,y; c_b12 t(.d_i(x),.d_o(y)); endmodule
EOF
run b12 b12.sv
# B13 BOTH habits in one module: a $unit ENUM constant net AND a phantom type-param net.
cat > b13.sv <<'EOF'
typedef enum logic [1:0] { UA, UB } eu_t;
typedef struct packed { logic [3:0] op; } d_t;
module c_b13 #(parameter type dtype = d_t) (input dtype d_i, output dtype d_o);
  logic [1:0] w;
  assign w = UA;
  assign d_o = d_i;
endmodule
module tb_b13; d_t x,y; c_b13 t(.d_i(x),.d_o(y)); endmodule
EOF
run b13 b13.sv
# B14 the name is a $unit typedef AND the parent also overrides the parameter.
cat > b14.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
typedef struct packed { logic [7:0] op; } o_t;
module c_b14 #(parameter type dtype = d_t) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module tb_b14; o_t x,y; c_b14 #(.dtype(o_t)) t(.d_i(x),.d_o(y)); endmodule
EOF
run b14 b14.sv

echo '--- NEGATIVE CONTROL ---'
run nc no_such_file_v11u37.sv

echo
echo "-- arms=$arms  compiled-nothing=$nothing (must be exactly 1: the nc control)"
pos=$(grep -c 'work@c_pc\.b' pc.dump; true)
echo "-- POSITIVE CONTROL (arm pc mints work@c_pc.b): $pos; must be >=1"
[ "$nothing" -eq 1 ] && [ "$pos" -ge 1 ] && echo "VGRID CONTROLS: PASS" || { echo "VGRID CONTROLS: FAIL"; exit 5; }
