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

echo '--- E. ORDER of minted nets when several sources feed one def ---'
# E1: the child mints its OWN key-1 default AND a key-2 name from its parent.
cat > e1.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
module c_e1 #(parameter type dtype = d_t) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module m_e1 (input logic [7:0] a, input logic [4:0] b, output logic [12:0] o);
  c_e1 #(.dtype(logic [$bits(a) + $bits(b) - 1:0])) u (.d_i(o), .d_o(o));
endmodule
module tb_e1; logic [12:0] o; m_e1 t(.a(8'd0),.b(5'd0),.o(o)); endmodule
EOF
run e1 e1.sv
# E2: two parents in REVERSE name order feed one child -- source order or name order?
cat > e2.sv <<'EOF'
module c_e2 #(parameter type dtype = logic) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module zp_e2 (input logic [7:0] za, input logic [4:0] zb, output logic [12:0] o);
  c_e2 #(.dtype(logic [$bits(za) + $bits(zb) - 1:0])) u (.d_i(o), .d_o(o));
endmodule
module ap_e2 (input logic [7:0] aa, input logic [4:0] ab, output logic [12:0] o);
  c_e2 #(.dtype(logic [$bits(aa) + $bits(ab) - 1:0])) u (.d_i(o), .d_o(o));
endmodule
module tb_e2; logic [12:0] o; zp_e2 t1(.za(8'd0),.zb(5'd0),.o(o)); ap_e2 t2(.aa(8'd0),.ab(5'd0),.o(o)); endmodule
EOF
run e2 e2.sv
echo "-- arms=$arms compiled-nothing=$nothing"
