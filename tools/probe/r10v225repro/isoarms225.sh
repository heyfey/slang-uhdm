#!/usr/bin/env bash
# r10v225 — rebuild the two ISOLATION arms of §2 into a scratch grid and run
# them.  They live here rather than in `vgrid225/` because each one isolates a
# single defect and its whole value is the three-binary table in the README;
# `vgrid225/` is the standing adversarial grid.
#
#   usage: SLANG_UHDM=<binary> bash isoarms225.sh <outdir>
set -u
OUT=${1:?outdir}
HERE=$(cd "$(dirname "$0")" && pwd)
SCR=$(mktemp -d /tmp/v225iso.XXXXXX)
mkdir -p "$SCR/v11_clsspec" "$SCR/v12_netvectd"

cat > "$SCR/v11_clsspec/dut.sv" <<'EOF'
// r10v225 arm v11_clsspec — R-A's UNMEASURED CELL: a PARAMETERIZED class
// specialization as the associative index.  `Cp225` and `Cp225#()` resolve to
// the SAME specialization type and golden answers them differently, so the
// discriminator is SYNTACTIC.
class Cp225 #(int W = 4);
  int q;
endclass
class Cd225;
  int q;
endclass
class Ce225 #(int W = 4) extends Cd225;
  int r;
endclass
package p225p;
  class Cq225 #(int W = 2);
    int z;
  endclass
endpackage
typedef Cp225#(3) tcp225_t;
typedef logic [7:0] tvz_t;

interface if225v_cs();
  tvz_t z_plain   [Cd225];
  tvz_t z_defgen  [Cp225];
  tvz_t z_spec2   [Cp225#(2)];
  tvz_t z_spec4   [Cp225#(4)];
  tvz_t z_specnp  [Cp225#()];
  tvz_t z_derspec [Ce225#(2)];
  tvz_t z_pkgspec [p225p::Cq225#(5)];
  tvz_t z_tdspec  [tcp225_t];
  tvz_t z_str     [string];
endinterface

module top225v_cs(); endmodule
EOF

cat > "$SCR/v12_netvectd/dut.sv" <<'EOF'
// r10v225 arm v12_netvectd — the inner element net's `vpiNetType` for a real
// NET (not a variable) declared with a VECTOR TYPEDEF and an unpacked
// dimension, every net keyword, instantiated and uninstantiated.  A net of a
// two-state, queue or associative type is illegal SV, so the reachable forms
// are exactly these.
typedef logic [7:0] tvk_t;
typedef reg   [7:0] trk_t;

interface if225v_nu();
  wire tvk_t u_wire [1:0];
  wand tvk_t u_wand [1:0];
  wor  tvk_t u_wor  [1:0];
  tri  tvk_t u_tri  [1:0];
  wire trk_t u_reg  [1:0];
  wire logic [3:0] u_inline [1:0];
endinterface

interface if225v_ni();
  wire tvk_t n_wire [1:0];
  wand tvk_t n_wand [1:0];
  wor  tvk_t n_wor  [1:0];
  tri  tvk_t n_tri  [1:0];
  wire trk_t n_reg  [1:0];
  wire logic [3:0] n_inline [1:0];
endinterface

module top225v_nv();
  if225v_ni u_ni();
endmodule
EOF

bash "$HERE/grid225.sh" "$OUT" "$SCR"
echo "isoarms225: sources kept at $SCR"
