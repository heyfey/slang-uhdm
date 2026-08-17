#!/usr/bin/env python3
"""r10vrgg3/gen.py — the ADVERSARIAL grid for r10rgg3's
§ portViewRangeRecvParams / § ifaceArrayElemViewFoldsDefault.

Written INDEPENDENTLY of tools/probe/r10rgg3repro/gen_grid.py: every cell here
is a shape that directory does NOT contain.  Each writes <cell>/dut.sv with a
top module named `top`.  MEASUREMENT-ONLY — the official uhdm-cmp is the judge
(run.sh) and the range agreement (score2.sh) is only ever read as a DIRECTION.
"""
import os

CELLS = {}
CELLS['q1_iface_recv_is_iface'] = r"""interface itf #(parameter int AW = 16, parameter int BW = 32,
                parameter int VW = BW);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
  logic [VW-1:0] v;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  modport mp (input a, b, v);
endinterface
interface recvif #(parameter int AW = 5)(itf.mp p[3]);
  logic [AW-1:0] q;
endinterface
module top;
  itf #(8, 32, 64) arr[3]();
  recvif ur (.p(arr));
endmodule
"""
CELLS['q2_virtual_iface'] = r"""interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  modport mp (input a);
endinterface
module recv #(parameter int AW = 5)(itf.mp p[3]);
  virtual itf vi;
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['q3_sig_collision'] = r"""interface itf #(parameter bit [3:0] AW = 12);
  logic [AW-1:0] a;
  modport mp (input a);
endinterface
module recvA #(parameter int AW = 20)(itf.mp p[3]);
endmodule
module recvB #(parameter logic [7:0] AW = 4)(itf.mp p[3]);
endmodule
module top;
  itf #(9) arr[3]();
  recvA ua (.p(arr));
  recvB ub (.p(arr));
endmodule
"""
CELLS['v10_genloop_stress'] = r"""interface itf #(parameter int AW = 2);
  logic [AW-1:0] a;
  for (genvar i = 0; i < AW; i++) begin : gl
    logic w;
  end
  modport mp (input a);
endinterface
module recv #(parameter int AW = 3000)(itf.mp p[3]);
endmodule
module top;
  itf #(2) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['v11_unpacked_stress'] = r"""interface itf #(parameter int AW = 4);
  logic [7:0] mem [AW];
  logic [AW-1:0] a;
  modport mp (input a);
endinterface
module recv #(parameter int AW = 65536)(itf.mp p[3]);
endmodule
module top;
  itf #(4) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['v12_reversed_range'] = r"""interface itf #(parameter int AW = 16);
  logic [0:AW-1] a;
  logic [AW:AW+7] rv;
  modport mp (input a);
endinterface
module recv #(parameter int AW = 3)(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['v13_recv_clog2'] = r"""interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  modport mp (input a);
endinterface
module recv #(parameter int N = 100)(itf.mp p[3]);
  localparam int AW = $clog2(N);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['v14_iface_lp_derived'] = r"""interface itf #(parameter int AW = 16);
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  logic [AW-1:0] a;
  modport mp (input a);
endinterface
module recv #(parameter int AW = 5, parameter int LP = 100)(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['v1_recv_aw_zero'] = r"""interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  modport mp (input a);
endinterface
module recv #(parameter int AW = 0)(itf.mp p[3]);
  logic [AW:0] own;
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['v2_recv_aw_negative'] = r"""interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  modport mp (input a);
endinterface
module recv #(parameter int AW = -3)(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['v3_recv_aw_huge'] = r"""interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  modport mp (input a);
endinterface
module recv #(parameter int AW = 100000)(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['v4_recv_aw_unpacked_dim'] = r"""interface itf #(parameter int AW = 4);
  logic [7:0] mem [AW];
  logic [AW-1:0] a;
  modport mp (input a);
endinterface
module recv #(parameter int AW = 2)(itf.mp p[3]);
endmodule
module top;
  itf #(4) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['v5_iface_gen_depends_on_aw'] = r"""interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  if (AW > 8) begin : gbig
    logic big;
  end else begin : gsml
    logic sml;
  end
  modport mp (input a);
endinterface
module recv #(parameter int AW = 4)(itf.mp p[3]);
endmodule
module top;
  itf #(16) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['v6_iface_genloop_bound_aw'] = r"""interface itf #(parameter int AW = 2);
  logic [AW-1:0] a;
  for (genvar i = 0; i < AW; i++) begin : gl
    logic w;
  end
  modport mp (input a);
endinterface
module recv #(parameter int AW = 5)(itf.mp p[3]);
endmodule
module top;
  itf #(2) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['v7_iface_assert_range'] = r"""interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  logic [AW-9:0] narrow;
  modport mp (input a);
endinterface
module recv #(parameter int AW = 4)(itf.mp p[3]);
endmodule
module top;
  itf #(16) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['v8_iface_div_by_aw'] = r"""interface itf #(parameter int AW = 4);
  localparam int Q = 64 / AW;
  logic [Q-1:0] q;
  logic [AW-1:0] a;
  modport mp (input a);
endinterface
module recv #(parameter int AW = 0)(itf.mp p[3]);
endmodule
module top;
  itf #(4) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['v9_recv_aw_intmax'] = r"""interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  modport mp (input a);
endinterface
module recv #(parameter int AW = 2147483647)(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['w1_member_kinds'] = r"""interface itf #(parameter int AW = 16, parameter int NW = 4);
  typedef logic [AW-1:0] word_t;
  typedef struct packed { logic [AW-1:0] f; logic [NW-1:0] g; } st_t;
  logic  [AW-1:0] a;
  wire   [AW-1:0] wn;
  reg    [AW-1:0] rg;
  bit    [AW-1:0] bt;
  byte            by;
  word_t          w;
  st_t            s;
  logic  [AW-1:0] arr2 [NW];
  logic  [AW-1:0][NW-1:0] two_d;
  logic signed [AW-1:0] sg;
  modport mp (input a, w, s);
endinterface
module recv #(parameter int AW = 5, parameter int NW = 2)(itf.mp p[3]);
endmodule
module top;
  itf #(8, 4) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['w2_member_enum_string_real'] = r"""interface itf #(parameter int AW = 16);
  typedef enum logic [AW-1:0] { E0, E1 } e_t;
  e_t            e;
  logic [AW-1:0] a;
  real           r;
  string         st;
  event          ev;
  modport mp (input a, e);
endinterface
module recv #(parameter int AW = 5)(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['w3_iface_func_uses_aw'] = r"""interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  function automatic logic [AW-1:0] f(input logic [AW-1:0] x);
    return x + 1;
  endfunction
  logic [AW-1:0] y;
  assign y = f(a);
  modport mp (input a);
endinterface
module recv #(parameter int AW = 5)(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['w4_iface_contassign_const'] = r"""interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  logic [AW-1:0] c;
  assign c = AW;
  modport mp (input a);
endinterface
module recv #(parameter int AW = 5)(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['x1_mixed_override_arr'] = r"""interface itf #(parameter int AW = 16, parameter int BW = 32,
                parameter int VW = BW);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
  logic [VW-1:0] v;
  wire  [AW-1:0] wn;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  modport mp (input a, b, v);
endinterface
module recv #(parameter int AW = 5, parameter int VW = 11)(itf.mp p[3]);
endmodule
module top;
  itf #(.AW(8), .VW(64)) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['x2_named_only_override_single'] = r"""interface itf #(parameter int AW = 16, parameter int BW = 32,
                parameter int VW = BW);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
  logic [VW-1:0] v;
  wire  [AW-1:0] wn;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  modport mp (input a, b, v);
endinterface

module recv #(parameter int AW = 5)(itf p);
endmodule
module top;
  itf #(.AW(8), .BW(32)) inst();
  recv u (.p(inst));
endmodule
"""
CELLS['x3_plain_positional_single'] = r"""interface itf #(parameter int AW = 16, parameter int BW = 32,
                parameter int VW = BW);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
  logic [VW-1:0] v;
  wire  [AW-1:0] wn;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  modport mp (input a, b, v);
endinterface

module recv #(parameter int AW = 5)(itf p);
endmodule
module top;
  itf #(8, 32, 64) inst();
  recv u (inst);
endmodule
"""
CELLS['x4_arr_2d'] = r"""interface itf #(parameter int AW = 16, parameter int BW = 32,
                parameter int VW = BW);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
  logic [VW-1:0] v;
  wire  [AW-1:0] wn;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  modport mp (input a, b, v);
endinterface

module recv #(parameter int AW = 5)(itf.mp p[2][3]);
endmodule
module top;
  itf #(8, 32, 64) arr[2][3]();
  recv u (.p(arr));
endmodule
"""
CELLS['x5_iface_in_generate'] = r"""interface itf #(parameter int AW = 16, parameter int BW = 32,
                parameter int VW = BW);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
  logic [VW-1:0] v;
  wire  [AW-1:0] wn;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  modport mp (input a, b, v);
endinterface

module recv #(parameter int AW = 5)(itf.mp p[3]);
endmodule
module top;
  for (genvar i = 0; i < 1; i++) begin : g
    itf #(8, 32, 64) arr[3]();
    recv u (.p(arr));
  end
endmodule
"""
CELLS['x6_recv_in_generate'] = r"""interface itf #(parameter int AW = 16, parameter int BW = 32,
                parameter int VW = BW);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
  logic [VW-1:0] v;
  wire  [AW-1:0] wn;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  modport mp (input a, b, v);
endinterface

module recv #(parameter int AW = 5)(itf.mp p[3]);
endmodule
module top;
  itf #(8, 32, 64) arr[3]();
  for (genvar i = 0; i < 2; i++) begin : g
    recv u (.p(arr));
  end
endmodule
"""
CELLS['x7_two_recvs_diff_aw'] = r"""interface itf #(parameter int AW = 16, parameter int BW = 32,
                parameter int VW = BW);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
  logic [VW-1:0] v;
  wire  [AW-1:0] wn;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  modport mp (input a, b, v);
endinterface

module recvA #(parameter int AW = 5)(itf.mp p[3]);
endmodule
module recvB #(parameter int AW = 9)(itf.mp p[3]);
endmodule
module top;
  itf #(8, 32, 64) arr[3]();
  recvA ua (.p(arr));
  recvB ub (.p(arr));
endmodule
"""
CELLS['x8_same_recv_two_insts_diff_ovr'] = r"""interface itf #(parameter int AW = 16, parameter int BW = 32,
                parameter int VW = BW);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
  logic [VW-1:0] v;
  wire  [AW-1:0] wn;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  modport mp (input a, b, v);
endinterface

module recv #(parameter int AW = 5)(itf.mp p[3]);
endmodule
module top;
  itf #(8, 32, 64) arr[3]();
  recv #(.AW(6)) u1 (.p(arr));
  recv #(.AW(11)) u2 (.p(arr));
endmodule
"""
CELLS['x9_nested_iface_port'] = r"""interface itf #(parameter int AW = 16, parameter int BW = 32,
                parameter int VW = BW);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
  logic [VW-1:0] v;
  wire  [AW-1:0] wn;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  modport mp (input a, b, v);
endinterface

module mid #(parameter int AW = 7)(itf.mp p[3]);
  recv u (.p(p));
endmodule
module recv #(parameter int AW = 4)(itf.mp p[3]);
endmodule
module top;
  itf #(8, 32, 64) arr[3]();
  mid um (.p(arr));
endmodule
"""
CELLS['xa_iface_inside_iface'] = r"""interface inner #(parameter int AW = 16);
  logic [AW-1:0] ia;
  modport mp (input ia);
endinterface
interface outer #(parameter int AW = 16);
  logic [AW-1:0] oa;
  inner #(AW) ui();
  modport mp (input oa);
endinterface
module recv #(parameter int AW = 5)(outer.mp p[3]);
endmodule
module top;
  outer #(8) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['xb_module_array_contrast'] = r"""module sub #(parameter int AW = 16)(input logic [AW-1:0] i);
  logic [AW-1:0] q;
endmodule
module recv #(parameter int AW = 5)(input logic [7:0] x);
  logic [7:0] w;
  sub #(8) s[3](.i(w));
endmodule
module top;
  logic [7:0] t;
  recv u (.x(t));
endmodule
"""
CELLS['xc_recv_localparam_only'] = r"""interface itf #(parameter int AW = 16, parameter int BW = 32,
                parameter int VW = BW);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
  logic [VW-1:0] v;
  wire  [AW-1:0] wn;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  modport mp (input a, b, v);
endinterface

module recv (itf.mp p[3]);
  localparam int AW = 5;
endmodule
module top;
  itf #(8, 32, 64) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['xd_recv_param_string'] = r"""interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  modport mp (input a);
endinterface
module recv #(parameter string AW = "hi")(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['xe_recv_param_real'] = r"""interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  modport mp (input a);
endinterface
module recv #(parameter real AW = 5.0)(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['xf_iface_localparam_name_clash'] = r"""interface itf #(parameter int AW = 16);
  localparam int LP = 8;
  logic [LP-1:0] lpm;
  logic [AW-1:0] a;
  modport mp (input a);
endinterface
module recv #(parameter int LP = 3)(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['xg_iface_untyped_param'] = r"""interface itf #(parameter AW = 16);
  logic [AW-1:0] a;
  modport mp (input a);
endinterface
module recv #(parameter AW = 5)(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['xh_recv_param_4state_x'] = r"""interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  modport mp (input a);
endinterface
module recv #(parameter logic [31:0] AW = 32'hx)(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['xi_iface_param_type'] = r"""interface itf #(parameter type T = logic [15:0]);
  T a;
  modport mp (input a);
endinterface
module recv #(parameter type T = logic [4:0])(itf.mp p[3]);
endmodule
module top;
  itf #(logic [7:0]) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['xj_recv_param_hier_dependent'] = r"""interface itf #(parameter int AW = 16, parameter int BW = 32,
                parameter int VW = BW);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
  logic [VW-1:0] v;
  wire  [AW-1:0] wn;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  modport mp (input a, b, v);
endinterface

module recv #(parameter int AW = 5)(itf.mp p[3]);
  localparam int BW = $bits(p[0].a);
  logic [BW-1:0] q;
endmodule
module top;
  itf #(8, 32, 64) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['xk_iface_no_default_param'] = r"""interface itf #(parameter int AW = 16, parameter int NOD = AW*2);
  logic [NOD-1:0] a;
  modport mp (input a);
endinterface
module recv #(parameter int AW = 5)(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['xl_deep_transitive'] = r"""interface itf #(parameter int AW = 16, parameter int B1 = AW*2,
                parameter int B2 = B1+1, parameter int B3 = B2*2);
  logic [B3-1:0] a;
  logic [AW-1:0] s;
  modport mp (input a);
endinterface
module recv #(parameter int AW = 3)(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['xm_modport_expr'] = r"""interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  logic [AW-1:0] b;
  modport mp (input .aa(a[AW-1:0]), input b);
endinterface
module recv #(parameter int AW = 5)(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['y1_elem_index_recvp'] = r"""interface itf #(parameter int AW = 16, parameter int BW = 32,
                parameter int VW = BW);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
  logic [VW-1:0] v;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  modport mp (input a, b, v);
endinterface
module recv #(parameter int AW = 5)(itf.mp p);
endmodule
module top;
  itf #(8, 32, 64) arr[3]();
  recv u (.p(arr[1]));
endmodule
"""
CELLS['y2_modport_used'] = r"""interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  logic clk;
  modport mp (input a, clk);
endinterface
module recv #(parameter int AW = 5)(itf.mp p[3]);
  logic [AW-1:0] q;
  always_comb q = p[0].a;
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['y3_recv_bw_only'] = r"""interface itf #(parameter int AW = 16, parameter int BW = 32,
                parameter int VW = BW);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
  logic [VW-1:0] v;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  modport mp (input a, b, v);
endinterface
module recv #(parameter int BW = 7)(itf.mp p[3]);
endmodule
module top;
  itf #(8, 32, 64) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['y4_iface_param_in_sub'] = r"""module leaf #(parameter int W = 1)(input logic [W-1:0] i);
endmodule
interface itf #(parameter int AW = 16);
  logic [AW-1:0] a;
  leaf #(AW) ul (.i(a));
  modport mp (input a);
endinterface
module recv #(parameter int AW = 5)(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['z1_single_genfor_named'] = r"""interface itf #(parameter int AW = 16, parameter int BW = 32,
                parameter int VW = BW);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
  logic [VW-1:0] v;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  modport mp (input a, b, v);
endinterface
module recv #(parameter int AW = 5)(itf.mp p);
endmodule
module top;
  for (genvar i = 0; i < 2; i++) begin : g
    itf #(8, 32, 64) inst();
    recv u (.p(inst));
  end
endmodule
"""
CELLS['z2_recv_module_array'] = r"""interface itf #(parameter int AW = 16, parameter int BW = 32,
                parameter int VW = BW);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
  logic [VW-1:0] v;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  modport mp (input a, b, v);
endinterface
module recv #(parameter int AW = 5)(itf.mp p);
endmodule
module top;
  itf #(8, 32, 64) arr[3]();
  recv u[3] (.p(arr));
endmodule
"""
CELLS['z5_textmulti_arr_norecvp'] = r"""interface itf #(parameter int AW = 16, parameter int BW = 32,
                parameter int VW = BW);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
  logic [VW-1:0] v;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  modport mp (input a, b, v);
endinterface
module recv (itf.mp p[3]);
endmodule
module other;
  itf #(.AW(8), .BW(32), .VW(64)) o1();
endmodule
module top;
  itf #(8, 32, 64) arr[3]();
  other uo ();
  recv u (.p(arr));
endmodule
"""
CELLS['z6_gen_arr_norecvp'] = r"""interface itfg #(parameter int AW = 16, parameter int BW = 32,
                 parameter int VW = BW);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
  logic [VW-1:0] v;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  if (1) begin : g
    logic gsig;
  end
  modport mp (input a, b, v);
endinterface
module recv (itfg.mp p[3]);
endmodule
module top;
  itfg #(8, 32, 64) arr[3]();
  recv u (.p(arr));
endmodule
"""
CELLS['z9_multiparam_arr_valdiff'] = r"""interface itf #(parameter int AW = 16, parameter int BW = 32,
                parameter int VW = BW);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
  logic [VW-1:0] v;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  modport mp (input a, b, v);
endinterface
module recv (itf.mp p[3]);
endmodule
module other;
  itf #(4, 16, 16) o1();
endmodule
module top;
  itf #(8, 32, 64) arr[3]();
  other uo ();
  recv u (.p(arr));
endmodule
"""

if __name__ == '__main__':
    root = os.path.dirname(os.path.abspath(__file__))
    for n, t in CELLS.items():
        d = os.path.join(root, n)
        os.makedirs(d, exist_ok=True)
        open(os.path.join(d, 'dut.sv'), 'w').write(t)
    print('cells:', len(CELLS))
