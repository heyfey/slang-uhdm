#!/usr/bin/env bash
# r11u37 GOLDEN GRID — § typeParamNameMintsDefNet37.
#
# GOLDEN-ONLY measurement: every arm is compiled by the PINNED Surelog and the
# question asked of each database is "which def-view logic_nets does the module
# carry".  Nothing here builds or runs slang-uhdm.
#
#   usage: ./goldengrid.sh [outdir]      (default: a mktemp -d)
#
# CONTROLS, both mandatory:
#   * POSITIVE — arm `ab` MUST mint `b` in the child def (the corpus witness
#     param_type_logic_width, reduced to one file).  An arm set that mints
#     nothing anywhere is a broken harness, not a golden fact.
#   * NEGATIVE — arm `zz` names a source file that does not exist; it must read
#     rc!=0 and HOLDERS=0 and be flagged ARM COMPILED NOTHING.  Every arm's rc
#     and top-level holder count is printed, so an arm whose compile failed can
#     never be read as "golden mints nothing here".
set -u
OUT=${1:-$(mktemp -d /tmp/r11u37grid.XXXXXX)}
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -x "$SL" ] || { echo "FATAL: no surelog at $SL"; exit 3; }
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump at $DUMP"; exit 3; }
mkdir -p "$OUT" || exit 3
cd "$OUT" || exit 3
echo "grid outdir: $OUT"
echo "surelog:     $SL"

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
  printf '%-6s rc=%-2s holders=%-2s nets: ' "$n" "$rc" "$h"
  if [ "$h" -eq 0 ]; then echo '!! ARM COMPILED NOTHING'; nothing=$((nothing+1)); return; fi
  grep -o 'logic_net: (work@[A-Za-z_0-9.]*), line:[0-9:]*' "$n.dump" \
    | sed 's/logic_net: //' | sort -u | tr '\n' ' '
  echo
}

# ---- family A: the ranged type-param OVERRIDE (the child gets the wire) ----
# `a` is [7:0] and `b` is [W-1:0]; both are declared in the INSTANTIATING module.
mkA() {  # mkA <arm> <override-actual>
cat > "$1.sv" <<EOF
module c_$1 #(parameter type dtype = logic) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module m_$1 #(parameter int W = 5) (input logic [7:0] a, input logic [W-1:0] b, output logic [12:0] o);
  c_$1 #(.dtype($2)) u (.d_i(o), .d_o(o));
endmodule
module tb_$1; logic [12:0] o; m_$1 #(.W(5)) t(.a(8'd0),.b(5'd0),.o(o)); endmodule
EOF
run "$1" "$1.sv"
}
echo '--- A. ranged type-parameter OVERRIDE: which names mint in the CHILD def ---'
mkA ab    'logic [$bits(a) + $bits(b) - 1:0]'          # POSITIVE CONTROL -> b
mkA ba    'logic [$bits(b) + $bits(a) - 1:0]'          # -> a
mkA aa    'logic [$bits(a) + $bits(a) - 1:0]'          # -> a (the SECOND one)
mkA aonly 'logic [$bits(a) - 1:0]'                     # -> none
mkA bonly 'logic [$bits(b) - 1:0]'                     # -> none
mkA p1    'logic [1 + $bits(a) - 1:0]'                 # -> a
mkA p2    'logic [a + b - 1:0]'                        # -> b
mkA p3    'logic [$bits(a) + $bits(b) + $bits(a) - 1:0]' # -> b, a
mkA p4    'logic [$bits(a) * $bits(b) - 1:0]'          # -> b
mkA p5    'logic [$bits(b):0]'                         # -> none
mkA p6    'logic [$bits(a) + $bits(b):0]'              # -> b
mkA s1    'logic [$bits(a) + ($bits(b) * 2) - 1:0]'    # -> b
mkA s2    'logic [($bits(a) + 1) + $bits(b) - 1:0]'    # -> b
mkA s3    'logic [$bits(a) + $bits(b[0]) - 1:0]'       # -> none (indexed name)
mkA s4    'logic [-$bits(a) + 16 - 1:0]'               # -> a (chain dies at unary)
mkA s5    'logic [8 + W - 1:0]'                        # -> none (parameter folds)
mkA s6    'logic [$bits(a) + $bits(a) + $bits(b) - 1:0]' # -> a, b
mkA t1    'logic [$bits({a, b}) - 1:0]'                # -> a, b (chain dies at concat)
mkA t2    'logic [$bits({a, b, a}) - 1:0]'             # -> a, b
mkA t3    'logic [(-$bits(a)) - 1:0]'                  # -> a
mkA t4    'logic [$bits(a) + (-$bits(b)) - 1:0]'       # -> b
mkA t5    'logic [(1==1) ? $bits(a) : $bits(b):0]'     # -> none (ternary reduces)
mkA t6    'logic [$bits(a) - 1:$bits(b) - $bits(b)]'   # -> b once
mkA w1    'logic [$bits(zq) - 1:0]'                    # -> zq  (exempt but UNRESOLVABLE)
mkA w2    'logic [W + $bits(a) - 1:0]'                 # -> a
mkA w3    'logic [a - 1:0]'                            # -> none
mkA w4    'logic [$bits(a) + $bits(zq) - 1:0]'         # -> zq

echo '--- B. the bare type NAME as a type-parameter default ---'
cat > q3.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
module c_q3 #(parameter type dtype = d_t) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module tb_q3; d_t x, y; c_q3 t(.d_i(x), .d_o(y)); endmodule
EOF
run q3 q3.sv                       # -> d_t in the module's OWN def
cat > u1.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
module c_u1 #(parameter type dtype = d_t) (input dtype d_i, output dtype d_o);
  logic zz1;
  logic zz2;
  assign d_o = d_i;
endmodule
module tb_u1; d_t x,y; c_u1 t(.d_i(x), .d_o(y)); endmodule
EOF
run u1 u1.sv                       # -> d_t LAST, after every declared net; elab has none
cat > u2.sv <<'EOF'
package p; typedef struct packed { logic [3:0] op; } d_t; endpackage
module c_u2 #(parameter type dtype = p::d_t) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module tb_u2; p::d_t x,y; c_u2 t(.d_i(x), .d_o(y)); endmodule
EOF
run u2 u2.sv                       # -> none (package-QUALIFIED)
cat > u3.sv <<'EOF'
module c_u3 (input logic i, output logic o);
  typedef logic [3:0] l_t;
  localparam type dt2 = l_t;
  assign o = i;
endmodule
module tb_u3; logic i,o; c_u3 t(.i(i),.o(o)); endmodule
EOF
run u3 u3.sv                       # -> none (module-LOCAL typedef)
cat > v1a.svh <<'EOF'
typedef struct packed { logic [3:0] op; } e_t;
EOF
cat > v1.sv <<'EOF'
module c_v1 #(parameter type dtype = e_t) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module tb_v1; e_t x,y; c_v1 t(.d_i(x), .d_o(y)); endmodule
EOF
run v1 v1a.svh v1.sv               # -> e_t ($unit typedef from ANOTHER file)
cat > v2.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
module c_v2 #(parameter type dtype = d_t) (input dtype d_i, output dtype d_o);
  logic d_t;
  assign d_o = d_i;
endmodule
module tb_v2; d_t x,y; c_v2 t(.d_i(x), .d_o(y)); endmodule
EOF
run v2 v2.sv                       # -> the DECLARED net only, no phantom
cat > v3.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
module c_v3 (input logic i, output logic o);
  localparam type dt2 = d_t;
  assign o = i;
endmodule
module tb_v3; logic i,o; c_v3 t(.i(i),.o(o)); endmodule
EOF
run v3 v3.sv                       # -> d_t (BODY localparam type)
cat > v5.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
module c_v5 #(parameter type dtype = d_t) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
EOF
run v5 v5.sv                       # -> d_t even though nothing instantiates it
cat > y2.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
module c_y2 #(parameter type t1 = d_t, parameter type t2 = d_t) (input t1 d_i, output t2 d_o);
  assign d_o = d_i;
endmodule
module tb_y2; d_t x,y; c_y2 t(.d_i(x), .d_o(y)); endmodule
EOF
run y2 y2.sv                       # -> ONE d_t, at the FIRST default's span
cat > x1.sv <<'EOF'
package pk; typedef struct packed { logic [3:0] op; } k_t; endpackage
module c_x1 #(parameter type dtype = k_t) (input dtype d_i, output dtype d_o);
  import pk::*;
  assign d_o = d_i;
endmodule
module tb_x1; import pk::*; k_t x,y; c_x1 t(.d_i(x), .d_o(y)); endmodule
EOF
run x1 x1.sv                       # -> none (the MODULE carries the import)
cat > x2.sv <<'EOF'
package pk2; typedef struct packed { logic [3:0] op; } k2_t; endpackage
import pk2::*;
module c_x2 #(parameter type dtype = k2_t) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module tb_x2; k2_t x,y; c_x2 t(.d_i(x), .d_o(y)); endmodule
EOF
run x2 x2.sv                       # -> k2_t (the import is at $unit scope)
cat > r3.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
module c_r3 #(parameter type dtype = logic) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module m_r3; d_t x,y; c_r3 #(.dtype(d_t)) u (.d_i(x), .d_o(y)); endmodule
EOF
run r3 r3.sv                       # -> d_t in the PARENT (a bare-name OVERRIDE)
cat > y1.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
module c_y1 #(parameter type dtype = logic) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module m_y1 (input logic [7:0] a, output logic [12:0] o);
  c_y1 #(.dtype(logic [$bits(a) + $bits(d_t) - 1:0])) u (.d_i(o), .d_o(o));
endmodule
EOF
run y1 y1.sv                       # -> none ($bits(<type name>) makes no ref)

echo '--- C. controls: not a type parameter / other holders ---'
cat > q1.sv <<'EOF'
module c_q1 #(parameter int P = 1) (input logic [P-1:0] d_i, output logic [P-1:0] d_o);
  assign d_o = d_i;
endmodule
module m_q1 #(parameter int W = 5) (input logic [7:0] a, input logic [W-1:0] b, output logic [12:0] o);
  c_q1 #(.P($bits(a) + $bits(b))) u (.d_i(o), .d_o(o));
endmodule
module tb_q1; logic [12:0] o; m_q1 #(.W(5)) t(.a(8'd0),.b(5'd0),.o(o)); endmodule
EOF
run q1 q1.sv                       # -> none: a VALUE parameter override mints nothing
cat > q2.sv <<'EOF'
module c_q2 #(parameter type dtype = logic) (input dtype d_i, output dtype d_o);
  logic [1:0] b;
  assign d_o = d_i;
endmodule
module m_q2 #(parameter int W = 5) (input logic [7:0] a, input logic [W-1:0] b, output logic [12:0] o);
  c_q2 #(.dtype(logic [$bits(a) + $bits(b) - 1:0])) u (.d_i(o), .d_o(o));
endmodule
module tb_q2; logic [12:0] o; m_q2 #(.W(5)) t(.a(8'd0),.b(5'd0),.o(o)); endmodule
EOF
run q2 q2.sv                       # -> the CHILD's own b, no phantom
cat > r1.sv <<'EOF'
module c_r1 (input logic i, output logic o);
  logic [$bits(aa) + $bits(bb) - 1:0] w;
  assign o = i;
endmodule
module tb_r1; logic i,o; c_r1 t(.i(i),.o(o)); endmodule
EOF
run r1 r1.sv                       # -> aa, bb: the same habit on a PLAIN net range
cat > r2.sv <<'EOF'
module c_r2 #(parameter type dtype = logic [$bits(aa) + $bits(bb) - 1:0]) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module tb_r2; logic [7:0] x,y; c_r2 t(.d_i(x),.d_o(y)); endmodule
EOF
run r2 r2.sv                       # -> aa, bb (a RANGED default, both unresolvable)
cat > u4.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
interface i_u4 #(parameter type dtype = d_t) (); dtype w; endinterface
module tb_u4; i_u4 ii(); endmodule
EOF
run u4 u4.sv                       # -> the ELABORATED interface instance, not the def
cat > v4.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
program pg_v4 #(parameter type dtype = d_t) (); dtype w; initial w = '0; endprogram
module tb_v4; pg_v4 pp(); endmodule
EOF
run v4 v4.sv                       # -> none (PROGRAM holder)
cat > y3.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
class cl_y3 #(parameter type T = d_t); T v; endclass
module tb_y3; cl_y3 #() h; initial h = new(); endmodule
EOF
run y3 y3.sv                       # -> none (CLASS holder)

echo '--- NEGATIVE CONTROL: an arm whose compile reaches nothing ---'
run zz no_such_source_file.sv

echo
echo "-- arms=$arms  compiled-nothing=$nothing (must be exactly 1: the zz control)"
pos=$(grep -c 'work@c_ab\.b' ab.dump; true)
echo "-- POSITIVE CONTROL (arm ab mints work@c_ab.b): $pos occurrence(s); must be >=1"
[ "$nothing" -eq 1 ] && [ "$pos" -ge 1 ] && echo "GRID CONTROLS: PASS" || { echo "GRID CONTROLS: FAIL"; exit 5; }
