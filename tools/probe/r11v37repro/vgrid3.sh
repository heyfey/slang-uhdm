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

echo '--- D. holders and reachability ---'
cat > d1.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
module c_d1 #(parameter type dtype = d_t) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module tb_d1; logic q; endmodule
EOF
run d1 d1.sv
cat > d4.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
interface i_d4 #(parameter type dtype = d_t) (); dtype w; endinterface
module tb_d4; i_d4 ii(); endmodule
EOF
run d4 d4.sv
cat > d5.sv <<'EOF'
typedef struct packed { logic [3:0] op; } d_t;
program pg_d5 #(parameter type dtype = d_t) (); dtype w; initial w = '0; endprogram
module tb_d5; pg_d5 pp(); endmodule
EOF
run d5 d5.sv
echo "-- arms=$arms compiled-nothing=$nothing"
