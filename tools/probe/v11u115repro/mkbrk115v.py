#!/usr/bin/env python3
"""mkbrk115v.py <out-dir>: the r11u115 verifier's BREAK grid (face 1 / 2 / 2b / 3)."""
import os, sys
OUT = sys.argv[1]
PK = ("package pk; parameter int unsigned W = $clog2(4); parameter int S = 2; "
      "parameter logic [3:0] L = 2; parameter bit B1 = 1'b1; typedef logic [3:0] n_t; "
      "parameter n_t N = 3; parameter byte BY = 2; endpackage\n")
HDR = ("module top import pk::*; #(parameter int unsigned NUM_FB = 2) (input logic [NUM_FB-1:0] c, "
       "input logic s, t, input logic [2:0] q [NUM_FB], input logic [2:0] r [NUM_FB][4], "
       "output logic [2:0] y [NUM_FB], output logic [2:0] z [NUM_FB][4], output logic [7:0] m);\n")
A = {}
def f1(name, body):
    A['f1/' + name] = PK + HDR + body + "\nendmodule\n"
GF = "  for (genvar fb = 0; fb < NUM_FB; fb++) begin : g\n    %s\n  end\n  assign m = '0;"
GI = "  if (NUM_FB == 2) begin : g\n    %s\n  end\n  assign y[1] = '0;\n  assign m = '0;"
MS = "  %s\n  assign m = '0;"
# face 1: system-function argument shapes
f1('a01_gf_signed',  GF % "assign y[fb] = q[fb] + $signed(W);")
f1('a02_gf_unsigned',GF % "assign y[fb] = q[fb] + $unsigned(S);")
f1('a03_gf_bits',    GF % "assign y[fb] = q[fb] + $bits(W);")
f1('a04_gf_clog_bare',GF % "assign y[fb] = $clog2(W);")
f1('a05_gf_clog2x',  GF % "assign y[fb] = q[fb] + $clog2($clog2(W));")
f1('a06_gf_repl_sys',GF % "assign y[fb] = {{$clog2(W){1'b0}}, s};")
f1('a07_ms_signed',  MS % "assign y[0] = q[0] + $signed(W);\n  assign y[1] = q[1] + $clog2(L);")
f1('a08_gf_qual_sys',GF % "assign y[fb] = q[fb] + $clog2(pk::W);")
f1('a09_gi_sys_tern',GI % "assign y[0] = s ? $clog2(W) : q[0];")
f1('a18_gf_countones', GF % "assign y[fb] = q[fb] + $countones(W);")
f1('a19_gf_signed_S', GF % "assign y[fb] = q[fb] + $signed(S);")
f1('a20_gf_unsigned_W', GF % "assign y[fb] = q[fb] + $unsigned(W);")
f1('a21_ms_bits', MS % "assign y[0] = q[0] + $bits(W);\n  assign y[1] = '0;")
f1('a22_gf_bits_L', GF % "assign y[fb] = q[fb] + $bits(L);")
f1('a23_gf_size_q', GF % "assign y[fb] = q[fb] + $clog2(W + 1);")
f1('a24_gf_delay', GF % "assign #1 y[fb] = {{W{1'b0}}, s};")
f1('a25_gf_strength', "  wire [2:0] w [NUM_FB];\n  for (genvar fb = 0; fb < NUM_FB; fb++) begin : g\n    assign (strong0, weak1) w[fb] = {{W{1'b0}}, s};\n    assign y[fb] = w[fb];\n  end\n  assign m = '0;")
f1('a26_gf_twoinst', GF % "assign y[fb] = {{W{1'b0}}, s};")
A['f1/a27_iface_genfor'] = PK + ("interface bif import pk::*; (input logic s);\n  logic [2:0] y [2];\n  for (genvar fb = 0; fb < 2; fb++) begin : g\n    assign y[fb] = {{W{1'b0}}, s};\n  end\nendinterface\n"
    "module top (input logic s, output logic [2:0] o);\n  bif b (.s(s));\n  assign o = b.y[0];\nendmodule\n")
A['f1/a28_two_params'] = PK + ("module sub import pk::*; #(parameter int unsigned N = 2) (input logic s, output logic [2:0] y [N]);\n  for (genvar fb = 0; fb < N; fb++) begin : g\n    assign y[fb] = {{W{1'b0}}, s};\n  end\nendmodule\n"
    "module top (input logic s, output logic [2:0] a [2], output logic [2:0] b [3]);\n  sub #(2) u0 (.s(s), .y(a));\n  sub #(3) u1 (.s(s), .y(b));\nendmodule\n")
A['f1/a29_genfor_lhs_op_idx'] = PK + HDR + (GF % "assign z[fb][W-1] = s;\n    assign z[fb][0] = '0;") + "\nendmodule\n"
# face 1: typed kinds + positions
f1('a10_gf_typedef', GF % "assign y[fb] = c[fb] ? {{N{1'b0}}, s} : q[fb];")
f1('a11_gf_bit',     GF % "assign y[fb] = (B1 == c[fb]) ? q[fb] : '0;")
f1('a12_gf_byte',    GF % "assign y[fb] = q[fb] >> BY;")
f1('a13_gcase',      "  case (NUM_FB)\n    2: begin : gc\n      assign y[0] = {{W{1'b0}}, s};\n    end\n    default: begin : gd\n      assign y[0] = '0;\n    end\n  endcase\n  assign y[1] = '0;\n  assign m = '0;")
f1('a14_gf_nda',     GF % "wire [2:0] w = q[fb] + W;\n    assign y[fb] = w;")
f1('a15_gf_neg_shift',GF % "assign y[fb] = q[fb] <<< S;")
f1('a16_gf_mixed',   GF % "assign y[fb] = {{W{1'b0}}, s} + (q[fb] == W) + L;")
f1('a17_gfgf_nested',"  for (genvar fb = 0; fb < NUM_FB; fb++) begin : g\n    for (genvar k = 0; k < 1; k++) begin : h\n      assign y[fb] = {{W{1'b0}}, s};\n    end\n  end\n  assign m = '0;")
# face 1c: var_select shapes
f1('v01_gf_vs_lhs',  GF % "assign z[fb][W] = s;\n    assign z[fb][0] = '0;")
f1('v02_ms_vs_lhs',  MS % "assign z[0][W] = s;")
f1('v03_gf_vs_cat',  GF % "assign y[fb] = {r[fb][W][0], r[fb][S][1:0]};")
f1('v04_gf_vs_bits', GF % "assign y[fb] = r[fb][L];")
f1('v05_gf_vs_idxof',GF % "assign y[fb] = r[fb][r[fb][W][1:0]];")
f1('v06_gf_vs_psel', GF % "assign y[fb] = r[fb][W][W-:2];")
f1('v07_ms_vs_qual', MS % "assign y[0] = r[0][pk::W];")
f1('v08_gf_vs_neg',  GF % "assign y[fb] = r[fb][S];")
# face 2: interface-array element views / defaults
IT = ("interface itf #(parameter int A = 16, parameter int B = 32, parameter int C = B, parameter int D = A * 2) ();\n"
      "  logic [A-1:0] a;\n  logic [C-1:0] v;\n  logic [D-1:0] d;\n  modport m (input a, d, output v);\nendinterface\n")
def f2(name, txt): A['f2/' + name] = txt
f2('p01_sizedlit', "interface itf #(parameter logic [7:0] A = 8'h10, parameter int B = 32) ();\n  logic [A-1:0] a;\n  modport m (input a);\nendinterface\n"
   "module leaf (itf.m p);\nendmodule\nmodule dut ();\n  itf #(8'h08, 40) arr[2] ();\n  leaf u (.p(arr[0]));\nendmodule\n")
f2('p02_recv_wide', "interface itf #(parameter bit [3:0] A = 4) ();\n  logic [A-1:0] a;\n  modport m (input a);\nendinterface\n"
   "module leaf #(parameter int A = 100) (itf.m p);\nendmodule\nmodule dut ();\n  itf #(8) arr[2] ();\n  leaf u (.p(arr[0]));\nendmodule\n")
f2('p03_clog_recvB', "interface itf #(parameter int B = 32, parameter int C = $clog2(B)) ();\n  logic [C-1:0] v;\n  modport m (input v);\nendinterface\n"
   "module leaf #(parameter int B = 256) (itf.m p);\nendmodule\nmodule dut ();\n  itf #(64, 9) arr[2] ();\n  leaf u (.p(arr[0]));\nendmodule\n")
f2('p04_lp_bare_recvA', "interface itf #(parameter int A = 16) ();\n  localparam int L = A;\n  logic [L-1:0] a;\n  modport m (input a);\nendinterface\n"
   "module leaf #(parameter int A = 5) (itf.m p);\nendmodule\nmodule dut ();\n  itf #(8) arr[2] ();\n  leaf u (.p(arr[0]));\nendmodule\n")
f2('p05_lp_bare_norecv', "interface itf #(parameter int A = 16) ();\n  localparam int L = A;\n  logic [L-1:0] a;\n  modport m (input a);\nendinterface\n"
   "module leaf (itf.m p);\nendmodule\nmodule dut ();\n  itf #(8) arr[2] ();\n  leaf u (.p(arr[0]));\nendmodule\n")
f2('p06_pkgbare', "package pk; parameter int PW = 12; endpackage\ninterface itf import pk::*; #(parameter int A = 16, parameter int C = PW) ();\n  logic [C-1:0] v;\n  modport m (input v);\nendinterface\n"
   "module leaf (itf.m p);\nendmodule\nmodule dut ();\n  itf #(8, 20) arr[2] ();\n  leaf u (.p(arr[0]));\nendmodule\n")
f2('p07_elem_ovB_only', IT + "module leaf (itf.m p);\nendmodule\nmodule dut ();\n  itf #(.A(8), .B(40)) arr[2] ();\n  leaf u (.p(arr[0]));\nendmodule\n")
f2('p08_single_pl_named_recvA', IT + "module leaf #(parameter int A = 5) (itf p);\nendmodule\nmodule dut ();\n  itf #(8, 32, 64) i ();\n  leaf u (.p(i));\nendmodule\n")
f2('p09_multi_pl_recvA', IT + "module leaf #(parameter int A = 5) (itf p);\nendmodule\nmodule dut ();\n  itf #(8, 32, 64) i ();\n  itf #(9, 32, 64) j ();\n  leaf u (.p(i));\n  leaf w (.p(j));\nendmodule\n")
f2('p10_recv_ov_expr', IT + "module leaf #(parameter int A = 5, parameter int E = A + 1) (itf.m p);\nendmodule\nmodule dut ();\n  itf #(8, 32, 64) arr[2] ();\n  leaf #(.A(7)) u (.p(arr[1]));\nendmodule\n")
f2('p11_recv_D_lit', IT + "module leaf #(parameter int D = 3) (itf.m p);\nendmodule\nmodule dut ();\n  itf #(8, 32, 64) arr[2] ();\n  leaf u (.p(arr[0]));\nendmodule\n")
f2('p12_recv_unsigned', IT + "module leaf #(parameter int unsigned A = 32'hFFFF_FFF0) (itf.m p);\nendmodule\nmodule dut ();\n  itf #(8, 32, 64) arr[2] ();\n  leaf u (.p(arr[0]));\nendmodule\n")
f2('p13_two_elems_two_recv', IT + "module leaf #(parameter int A = 5) (itf.m p);\nendmodule\nmodule leaf2 (itf.m p);\nendmodule\nmodule dut ();\n  itf #(8, 32, 64) arr[2] ();\n  leaf u (.p(arr[0]));\n  leaf2 w (.p(arr[1]));\nendmodule\n")
f2('p14_untyped_recv_lit', "interface itf #(parameter A = 16, parameter C = A + 0) ();\n  logic [A-1:0] a;\n  modport m (input a);\nendinterface\n"
   "module leaf #(parameter A = 4'd5) (itf.m p);\nendmodule\nmodule dut ();\n  itf #(8) arr[2] ();\n  leaf u (.p(arr[0]));\nendmodule\n")
f2('p15_recv_hex8', IT + "module leaf #(parameter logic [7:0] A = 8'h0A) (itf.m p);\nendmodule\nmodule dut ();\n  itf #(8, 32, 64) arr[2] ();\n  leaf u (.p(arr[0]));\nendmodule\n")
f2('p16_recv_hex_unsized', IT + "module leaf #(parameter A = 'hA) (itf.m p);\nendmodule\nmodule dut ();\n  itf #(8, 32, 64) arr[2] ();\n  leaf u (.p(arr[0]));\nendmodule\n")
f2('p17_recv_B_hex_single', IT + "module leaf #(parameter logic [7:0] B = 8'h28) (itf p);\nendmodule\nmodule dut ();\n  itf #(8, 32, 64) i ();\n  leaf u (i);\nendmodule\n")
f2('p18_recv_wide101', "interface itf #(parameter bit [3:0] A = 4) ();\n  logic [A-1:0] a;\n  modport m (input a);\nendinterface\nmodule leaf #(parameter int A = 101) (itf.m p);\nendmodule\nmodule dut ();\n  itf #(8) arr[2] ();\n  leaf u (.p(arr[0]));\nendmodule\n")
f2('p19_recv_wide300_b8', "interface itf #(parameter bit [7:0] A = 4) ();\n  logic [A-1:0] a;\n  modport m (input a);\nendinterface\nmodule leaf #(parameter int A = 300) (itf.m p);\nendmodule\nmodule dut ();\n  itf #(8) arr[2] ();\n  leaf u (.p(arr[0]));\nendmodule\n")
f2('p20_recv_expr', IT + "module leaf #(parameter int A = 2 + 3) (itf.m p);\nendmodule\nmodule dut ();\n  itf #(8, 32, 64) arr[2] ();\n  leaf u (.p(arr[0]));\nendmodule\n")
f2('p21_recv_ov_hex', IT + "module leaf #(parameter int A = 5) (itf.m p);\nendmodule\nmodule dut ();\n  itf #(8, 32, 64) arr[2] ();\n  leaf #(.A(8'h07)) u (.p(arr[0]));\nendmodule\n")
# face 2b: named modport out-of-scope shapes
def mp(name, dut, leafhdr="module leaf (itf.m p);\nendmodule\n"):
    A['f2b/' + name] = IT + leafhdr + dut
mp('q01_genfor_same_iter', "module dut ();\n  for (genvar k = 0; k < 2; k++) begin : g\n    itf #(8, 32, 64) i ();\n    leaf u (.p(i));\n  end\nendmodule\n")
mp('q02_samegen_mpexpr', "module dut ();\n  if (1) begin : g\n    itf #(8, 32, 64) i ();\n    leaf u (.p(i.m));\n  end\nendmodule\n")
mp('q03_hier_into_gen', "module dut ();\n  if (1) begin : g\n    itf #(8, 32, 64) i ();\n  end\n  leaf u (.p(g.i));\nendmodule\n")
mp('q04_passport_genfor', "module mid (itf.m bp);\n  for (genvar k = 0; k < 2; k++) begin : g\n    leaf u (.p(bp));\n  end\nendmodule\nmodule dut ();\n  itf #(8, 32, 64) i ();\n  mid mm (.bp(i));\nendmodule\n")
mp('q05_multi_oos', "module dut ();\n  itf #(8, 32, 64) i ();\n  itf #(9, 32, 64) j ();\n  if (1) begin : g\n    leaf u (.p(i));\n  end\n  leaf w (.p(j));\nendmodule\n")
mp('q06_oos_recvA', "module dut ();\n  itf #(8, 32, 64) i ();\n  if (1) begin : g\n    leaf u (.p(i));\n  end\nendmodule\n", "module leaf #(parameter int A = 5) (itf.m p);\nendmodule\n")
mp('q07_genif_in_genif_samegen', "module dut ();\n  if (1) begin : g\n    itf #(8, 32, 64) i ();\n    if (1) begin : h\n      leaf u (.p(i));\n    end\n  end\nendmodule\n")
mp('q08_oos_default_iface', "module dut ();\n  itf i ();\n  if (1) begin : g\n    leaf u (.p(i));\n  end\nendmodule\n")
mp('q09_gencase_oos', "module dut ();\n  itf #(8, 32, 64) i ();\n  case (1)\n    1: begin : g\n      leaf u (.p(i));\n    end\n  endcase\nendmodule\n")
# face 3: type-parameter casts
TPH = "module top #(parameter int unsigned W = 2, parameter type idx_t = logic [W-1:0]) (input logic a, b, s, output logic [1:0] y, output logic [1:0] z);\n"
def f3(name, body): A['f3/' + name] = TPH + body + "\n  assign z = '0;\nendmodule\n"
f3('c01_dblparen', "  if (1) begin : g\n    assign y = ((idx_t'(a)));\n  end")
f3('c02_paren_underop', "  if (1) begin : g\n    assign y = (idx_t'(a)) + 2'd1;\n  end")
f3('c03_ifif_underop', "  if (1) begin : g\n    if (W == 2) begin : h\n      assign y = idx_t'(a) + 2'd1;\n    end\n  end")
f3('c04_gcase_underop', "  case (W)\n    2: begin : g\n      assign y = s ? idx_t'(a) : idx_t'(b);\n    end\n  endcase")
f3('c05_genif_concat', "  if (1) begin : g\n    assign y = {idx_t'(a)};\n  end")
f3('c06_genif_sys_underop', "  if (1) begin : g\n    assign y = $unsigned(idx_t'(a)) + 2'd1;\n  end")
f3('c07_genif_paren_tern', "  if (1) begin : g\n    assign y = s ? (idx_t'(a)) : idx_t'(b);\n  end")
f3('c08_genif_else_underop', "  if (W != 2) begin : g\n    assign y = '0;\n  end else begin : ge\n    assign y = idx_t'(a) + 2'd1;\n  end")
A['f3/o01_outer_for_lptype'] = ("module top (input logic a, output logic [1:0] y [2]);\n  for (genvar k = 0; k < 2; k++) begin : g\n    localparam type idx_t = logic [1:0];\n"
    "    if (1) begin : h\n      assign y[k] = idx_t'(a);\n    end\n  end\nendmodule\n")
A['f3/o02_outer_if_inner_for'] = ("module top (input logic a, output logic [1:0] y [2]);\n  if (1) begin : g\n    localparam type idx_t = logic [1:0];\n"
    "    for (genvar k = 0; k < 2; k++) begin : h\n      assign y[k] = idx_t'(a);\n    end\n  end\nendmodule\n")
A['f3/o03_three_level'] = ("module top (input logic a, output logic [1:0] y);\n  if (1) begin : g\n    localparam type idx_t = logic [1:0];\n"
    "    if (1) begin : h\n      if (1) begin : i\n        assign y = idx_t'(a);\n      end\n    end\n  end\nendmodule\n")
A['f3/o04_same_block_ctl'] = ("module top (input logic a, output logic [1:0] y);\n  if (1) begin : g\n    localparam type idx_t = logic [1:0];\n"
    "    assign y = idx_t'(a);\n  end\nendmodule\n")
A['f3/o05_outer_typedef'] = ("module top (input logic a, output logic [1:0] y);\n  if (1) begin : g\n    typedef logic [1:0] idx_t;\n"
    "    if (1) begin : h\n      assign y = idx_t'(a);\n    end\n  end\nendmodule\n")
A['f3/o06_outer_lptype_underop'] = ("module top (input logic a, output logic [1:0] y);\n  if (1) begin : g\n    localparam type idx_t = logic [1:0];\n"
    "    if (1) begin : h\n      assign y = idx_t'(a) + 2'd1;\n    end\n  end\nendmodule\n")
for k, v in A.items():
    d = os.path.join(OUT, k); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(v)
print(len(A))
