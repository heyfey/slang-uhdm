#!/usr/bin/env python3
# mkgrid113.py: writes grid/<face>/<arm>/dut.sv for the r11u113 golden grid.
import os, sys
root = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'grid')
A = {}
# ---- face 1 (b): a bare read of a typed parameter as a range bound ----
def pk(t, init='5', kw='parameter'):
    return f"package pk; {kw} {t} P = {init}; parameter {t} Q = 2; endpackage\n"
body = {
 'var':  "  logic [P:0] x;\n  assign x = i[{w}:0];\n  assign o = x;\n",
}
def mod(decls, ports="input logic [7:0] i, output logic [7:0] o", imp="import pk::*; "):
    return f"module top {imp}({ports});\n{decls}endmodule\n"
T = {'ius':'int unsigned','int':'int','intg':'integer','lg8':'logic [7:0]','bt8':'bit [7:0]','unt':'','byt':'byte','lint':'longint','sint':'shortint'}
for k,t in T.items():
    A[f'b/b01_var_{k}'] = pk(t) + mod("  logic [P:0] x;\n  assign x = i[5:0];\n  assign o = x;\n")
A['b/b02_right_ius'] = pk('int unsigned') + mod("  logic [7:P] x;\n  assign x = i[2:0];\n  assign o = x;\n")
A['b/b03_both_ius'] = pk('int unsigned') + mod("  logic [P:Q] x;\n  assign x = i[3:0];\n  assign o = x;\n")
A['b/b04_net_ius'] = pk('int unsigned') + mod("  wire [P:0] x;\n  assign x = i[5:0];\n  assign o = x;\n")
A['b/b05_port_ius'] = pk('int unsigned') + "module top import pk::*; (input logic [P:0] i, output logic [7:0] o);\n  assign o = i;\nendmodule\n"
A['b/b06_member_ius'] = pk('int unsigned') + mod("  typedef struct packed { logic [P:0] a; logic b; } s_t;\n  s_t x;\n  assign x = i[6:0];\n  assign o = x.a;\n")
A['b/b07_typedef_ius'] = pk('int unsigned') + mod("  typedef logic [P:0] t_t;\n  t_t x;\n  assign x = i[5:0];\n  assign o = x;\n")
A['b/b08_unpacked_ius'] = pk('int unsigned') + mod("  logic x [P:0];\n  assign x[0] = i[0];\n  assign o = x[0];\n")
A['b/b09_pk_unp_ius'] = pk('int unsigned') + mod("  logic [P:0] x [2];\n  assign x[0] = i[5:0];\n  assign x[1] = i[5:0];\n  assign o = x[1];\n")
A['b/b10_modhdr_ius_ctl'] = "module top #(parameter int unsigned P = 5) (input logic [7:0] i, output logic [7:0] o);\n  logic [P:0] x;\n  assign x = i[5:0];\n  assign o = x;\nendmodule\n"
A['b/b11_modlp_ius_ctl'] = "module top (input logic [7:0] i, output logic [7:0] o);\n  localparam int unsigned P = 5;\n  logic [P:0] x;\n  assign x = i[5:0];\n  assign o = x;\nendmodule\n"
A['b/b12_genlp_ius'] = "module top (input logic [7:0] i, output logic [7:0] o);\n  if (1) begin : g\n    localparam int unsigned P = 5;\n    logic [P:0] x;\n    assign x = i[5:0];\n    assign o = x;\n  end\nendmodule\n"
A['b/b13_pk_in_gen_ius'] = pk('int unsigned') + mod("  if (1) begin : g\n    logic [P:0] x;\n    assign x = i[5:0];\n    assign o = x;\n  end\n")
A['b/b14_qual_ius'] = pk('int unsigned') + mod("  logic [pk::P:0] x;\n  assign x = i[5:0];\n  assign o = x;\n", imp="")
A['b/b15_exprinit_ius'] = pk('int unsigned', init='2+3') + mod("  logic [P:0] x;\n  assign x = i[5:0];\n  assign o = x;\n")
A['b/b16_inner2d_ius'] = pk('int unsigned') + mod("  logic [1:0][P:0] x;\n  assign x = {i[5:0], i[5:0]};\n  assign o = x[1];\n")
A['b/b17_outer2d_ius'] = pk('int unsigned') + mod("  logic [P:0][1:0] x;\n  assign x = {i, i[3:0]};\n  assign o = x[1];\n")
A['b/b18_pklp_ius'] = pk('int unsigned', kw='localparam') + mod("  logic [P:0] x;\n  assign x = i[5:0];\n  assign o = x;\n")
A['b/b19_bodyimp_ius'] = pk('int unsigned') + mod("  import pk::*;\n  logic [P:0] x;\n  assign x = i[5:0];\n  assign o = x;\n", imp="")
A['b/b20_based_ius'] = pk('int unsigned', init="32'd5") + mod("  logic [P:0] x;\n  assign x = i[5:0];\n  assign o = x;\n")
A['b/b21_outport_ius'] = pk('int unsigned') + "module top import pk::*; (input logic [7:0] i, output logic [P:0] o);\n  assign o = i[5:0];\nendmodule\n"
A['b/b22_reg_ius'] = pk('int unsigned') + mod("  reg [P:0] x;\n  always_comb x = i[5:0];\n  assign o = x;\n")
A['b/b23_pmp_shape'] = pk('int unsigned', init='33') + "module top import pk::*; #(parameter int unsigned N = 2) (input logic [33:0] i, output logic [33:0] o);\n  logic [P:0] x [N];\n  for (genvar r = 0; r < N; r++) begin : g_r\n    assign x[r] = i;\n  end\n  assign o = x[1];\nendmodule\n"
A['b/b24_icache_shape'] = pk('int unsigned', init='1') + "module top import pk::*; #(parameter int unsigned NUM_FB = 4) (input logic [1:0] i, output logic [1:0] o);\n  logic [NUM_FB-1:0][P:0] x_d, x_q;\n  assign x_d = {NUM_FB{i}};\n  assign x_q = x_d;\n  assign o = x_q[0];\nendmodule\n"
A['b/b25_child_ius'] = pk('int unsigned') + "module c import pk::*; (input logic [7:0] i, output logic [7:0] o);\n  logic [P:0] x;\n  assign x = i[5:0];\n  assign o = x;\nendmodule\nmodule top (input logic [7:0] i, output logic [7:0] o);\n  c u (.i(i), .o(o));\nendmodule\n"
A['b/b26_unit_ius'] = "parameter int unsigned P = 5;\nmodule top (input logic [7:0] i, output logic [7:0] o);\n  logic [P:0] x;\n  assign x = i[5:0];\n  assign o = x;\nendmodule\n"
A['b/b27_pkpar_of_pkpar'] = "package pk; parameter int unsigned R = 5; parameter int unsigned P = R; endpackage\n" + mod("  logic [P:0] x;\n  assign x = i[5:0];\n  assign o = x;\n")
A['b/b28_var_int_signed_neg'] = pk('int', init='-1') + mod("  logic [7:P] x;\n  assign x = i;\n  assign o = x;\n")
A['b/b29_member_int'] = pk('int') + mod("  typedef struct packed { logic [P:0] a; logic b; } s_t;\n  s_t x;\n  assign x = i[6:0];\n  assign o = x.a;\n")
A['b/b30_logicvar_uint32'] = pk('logic [31:0]') + mod("  logic [P:0] x;\n  assign x = i[5:0];\n  assign o = x;\n")
# ---- face 2 (c): a cast to a type-parameter type ----
TP = "module top #(parameter int unsigned W = 2, parameter type idx_t = logic [W-1:0]) (input logic a, b, s, output logic [1:0] y, output logic [1:0] z);\n"
A['c/c01_arb'] = open(os.path.expanduser('~/git-repos/uhdm2rtlil/test/arb_idx_cast/dut.sv')).read()
A['c/c02_genif_ref'] = TP + "  if (W == 2) begin : g\n    assign y = idx_t'(a);\n  end\n  assign z = '0;\nendmodule\n"
A['c/c03_mod_ref'] = TP + "  assign y = idx_t'(a);\n  assign z = '0;\nendmodule\n"
A['c/c04_genfor_ref'] = TP + "  for (genvar k = 0; k < 1; k++) begin : g\n    assign y = idx_t'(a);\n  end\n  assign z = '0;\nendmodule\n"
A['c/c05_genif_concat'] = TP + "  if (W == 2) begin : g\n    assign y = idx_t'({a, b});\n  end\n  assign z = '0;\nendmodule\n"
A['c/c06_genif_ternary'] = TP + "  if (W == 2) begin : g\n    assign y = s ? idx_t'(a) : idx_t'(b);\n  end\n  assign z = '0;\nendmodule\n"
A['c/c07_genif_bodylp'] = "module top (input logic a, b, s, output logic [1:0] y);\n  localparam type idx_t = logic [1:0];\n  if (1) begin : g\n    assign y = idx_t'(a);\n  end\nendmodule\n"
A['c/c08_genif_bodyparam'] = "module top (input logic a, b, s, output logic [1:0] y);\n  parameter type idx_t = logic [1:0];\n  if (1) begin : g\n    assign y = idx_t'(a);\n  end\nendmodule\n"
A['c/c09_genif_modtd_ctl'] = "module top (input logic a, b, s, output logic [1:0] y);\n  typedef logic [1:0] idx_t;\n  if (1) begin : g\n    assign y = idx_t'(a);\n  end\nendmodule\n"
A['c/c10_genif_pkqual'] = "package pk; typedef logic [1:0] idx_t; endpackage\nmodule top (input logic a, b, s, output logic [1:0] y);\n  if (1) begin : g\n    assign y = pk::idx_t'(a);\n  end\nendmodule\n"
A['c/c11_genif_pkimp'] = "package pk; typedef logic [1:0] idx_t; endpackage\nmodule top import pk::*; (input logic a, b, s, output logic [1:0] y);\n  if (1) begin : g\n    assign y = idx_t'(a);\n  end\nendmodule\n"
A['c/c12_genif_override'] = "module c #(parameter type idx_t = logic [1:0]) (input logic a, output logic [2:0] y);\n  if (1) begin : g\n    assign y = idx_t'(a);\n  end\nendmodule\nmodule top (input logic a, output logic [2:0] y);\n  c #(.idx_t(logic [2:0])) u (.a(a), .y(y));\nendmodule\n"
A['c/c13_genif_comb'] = TP + "  if (W == 2) begin : g\n    always_comb y = idx_t'(a);\n  end\n  assign z = '0;\nendmodule\n"
A['c/c14_genif_intdef'] = "module top #(parameter type idx_t = int) (input logic a, output logic [31:0] y);\n  if (1) begin : g\n    assign y = idx_t'(a);\n  end\nendmodule\n"
A['c/c15_genif_structdef'] = "module top #(parameter type idx_t = struct packed { logic p; logic q; }) (input logic a, output logic [1:0] y);\n  if (1) begin : g\n    assign y = idx_t'(a);\n  end\nendmodule\n"
A['c/c16_mod_comb'] = TP + "  always_comb y = idx_t'(a);\n  assign z = '0;\nendmodule\n"
A['c/c17_genif_lit'] = TP + "  if (W == 2) begin : g\n    assign y = idx_t'(1);\n  end\n  assign z = '0;\nendmodule\n"
A['c/c18_genif_inop'] = TP + "  if (W == 2) begin : g\n    assign y = idx_t'(a) + 2'd1;\n  end\n  assign z = '0;\nendmodule\n"
A['c/c19_genif_lhs_bitsel'] = TP + "  logic [1:0] n [2];\n  if (W == 2) begin : g\n    assign n[0] = idx_t'(a);\n  end\n  assign y = n[0];\n  assign z = '0;\nendmodule\n"
A['c/c20_nested_genif'] = TP + "  if (W == 2) begin : g\n    if (W > 1) begin : h\n      assign y = idx_t'(a);\n    end\n  end\n  assign z = '0;\nendmodule\n"
A['c/c21_genelse'] = TP + "  if (W == 3) begin : g\n    assign y = '0;\n  end else begin : e\n    assign y = idx_t'(a);\n  end\n  assign z = '0;\nendmodule\n"
A['c/c22_genif_two'] = TP + "  if (W == 2) begin : g\n    assign y = idx_t'(a);\n    assign z = idx_t'(b);\n  end\nendmodule\n"
# ---- face 3 (e): an inline enum member of a struct typespec ----
A['e/e01_lptype_dims'] = open('/home/heyfey/git-repos/slang-uhdm/tools/probe/v11u112repro/grid/brk/k/b3b_enum_member/dut.sv').read()
A['e/e02_modtd'] = "module m(output logic [3:0] o);\n  typedef struct packed { enum logic [1:0] {A, B, C} e; logic [1:0] b; } s_t;\n  s_t x;\n  assign x = '0;\n  assign o = x;\nendmodule\n"
A['e/e03_pkgtd'] = "package pk; typedef struct packed { enum logic [1:0] {A, B, C} e; logic [1:0] b; } s_t; endpackage\nmodule m(output logic [3:0] o);\n  pk::s_t x;\n  assign x = '0;\n  assign o = x;\nendmodule\n"
A['e/e04_modtd_intenum'] = "module m(output logic [33:0] o);\n  typedef struct packed { enum {A, B, C} e; logic [1:0] b; } s_t;\n  s_t x;\n  assign x = '0;\n  assign o = x;\nendmodule\n"
A['e/e05_nested'] = "module m(output logic [4:0] o);\n  typedef struct packed { struct packed { enum logic [1:0] {A, B} e; logic c; } in; logic [1:0] b; } s_t;\n  s_t x;\n  assign x = '0;\n  assign o = x;\nendmodule\n"
A['e/e06_anon_var'] = "module m(output logic [3:0] o);\n  struct packed { enum logic [1:0] {A, B, C} e; logic [1:0] b; } x;\n  assign x = '0;\n  assign o = x;\nendmodule\n"
A['e/e07_lptype_scalar'] = "module m(output logic [3:0] o);\n  localparam type T = struct packed { enum logic [1:0] {A, B, C} e; logic [1:0] b; };\n  T x;\n  assign x = '0;\n  assign o = x;\nendmodule\n"
A['e/e08_modtd_dims'] = "module m(output logic [7:0] o);\n  typedef struct packed { enum logic [1:0] {A, B, C} e; logic [1:0] b; } s_t;\n  s_t [1:0] p;\n  assign p = '0;\n  assign o = p;\nendmodule\n"
A['e/e09_modtd_use'] = "module m(output logic [3:0] o);\n  typedef struct packed { enum logic [1:0] {A, B, C} e; logic [1:0] b; } s_t;\n  s_t x;\n  assign x.e = B;\n  assign x.b = '0;\n  assign o = x;\nendmodule\n"
A['e/e10_union'] = "module m(output logic [1:0] o);\n  typedef union packed { enum logic [1:0] {A, B, C} e; logic [1:0] b; } u_t;\n  u_t x;\n  assign x = '0;\n  assign o = x;\nendmodule\n"
A['e/e11_member_typed_enum_ctl'] = "module m(output logic [3:0] o);\n  typedef enum logic [1:0] {A, B, C} e_t;\n  typedef struct packed { e_t e; logic [1:0] b; } s_t;\n  s_t x;\n  assign x = '0;\n  assign o = x;\nendmodule\n"
A['e/e12_port'] = "module m(input struct packed { enum logic [1:0] {A, B, C} e; logic [1:0] b; } i, output logic [3:0] o);\n  assign o = i;\nendmodule\n"
for k, v in A.items():
    d = os.path.join(root, k); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(v)
print(len(A))
# ---- face 4 (q): ranged repetitions in a property DECLARATION body ----
def prop(body, clk="@(posedge clk) ", dis=""):
    return f"module m(input logic clk, rst, a, b, c);\n  property p1;\n    {clk}{dis}{body};\n  endproperty\n  a1: assert property (p1);\nendmodule\n"
Q = {'q01_star13':'a |-> b[*1:3]','q02_star02_ante':'a[*0:2] |-> b','q03_eq12':'a |-> b[=1:2]','q04_goto12':'a |-> b[->1:2]',
     'q05_star1inf':'a |-> b[*1:$]','q06_star2_ctl':'a |-> b[*2]','q07_eq2_ctl':'a |-> b[=2]','q08_star13_seq':'a |-> b[*1:3] ##1 c',
     'q09_star13_nonov':'a |=> b[*1:3]','q10_star_inf0':'a |-> b[*0:$]','q11_starplain':'a |-> b[*]','q12_plus':'a |-> b[+]'}
B = {}
for k, v in Q.items():
    B['q/' + k] = prop(v)
B['q/q13_star13_dis'] = prop('a |-> b[*1:3]', dis='disable iff (rst) ')
B['q/q14_star13_noclk'] = "module m(input logic clk, rst, a, b, c);\n  property p1;\n    a |-> b[*1:3];\n  endproperty\n  a1: assert property (@(posedge clk) p1);\nendmodule\n"
B['q/q15_inline_ctl'] = "module m(input logic clk, rst, a, b, c);\n  a1: assert property (@(posedge clk) a |-> b[*1:3]);\nendmodule\n"
for k, v in B.items():
    d = os.path.join(root, k); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(v)
print(len(B))
# ---- face 2 extension: the genvar-dependent operand (arb's gen_other_levels) ----
TP2 = "module top #(parameter int unsigned W = 2, parameter type idx_t = logic [W-1:0]) (input logic a, b, s, input logic [1:0] v, output logic [1:0] n [2]);\n"
C = {
 'c/c23_genfor_concat': TP2 + "  for (genvar k = 0; k < 2; k++) begin : g\n    assign n[k] = idx_t'({a, b});\n  end\nendmodule\n",
 'c/c24_genfor_gvop': TP2 + "  for (genvar k = 0; k < 2; k++) begin : g\n    assign n[k] = idx_t'({1'b1, v[k]});\n  end\nendmodule\n",
 'c/c25_genfor_ternary_gvcast': TP2 + "  for (genvar k = 0; k < 2; k++) begin : g\n    assign n[k] = s ? idx_t'({1'b1, v[unsigned'(k)]}) : idx_t'({1'b0, v[0]});\n  end\nendmodule\n",
 'c/c26_genfor_gvsel': TP2 + "  for (genvar k = 0; k < 2; k++) begin : g\n    assign n[k] = idx_t'(v[k]);\n  end\nendmodule\n",
 'c/c27_genfor_ternary_plain': TP2 + "  for (genvar k = 0; k < 2; k++) begin : g\n    assign n[k] = s ? idx_t'(a) : idx_t'(b);\n  end\nendmodule\n",
 'c/c28_genfor_lp_sel': TP2 + "  for (genvar k = 0; k < 2; k++) begin : g\n    localparam int unsigned L = k;\n    assign n[k] = idx_t'(v[L]);\n  end\nendmodule\n",
}
for k, v in C.items():
    d = os.path.join(root, k); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(v)
print(len(C))
# ---- face 5 (v): a typed package parameter read under a VAR_SELECT element-index operation ----
PK = "package pk; parameter int unsigned P = 4; parameter int S = 4; parameter U = 4; endpackage\n"
HD = "module top import pk::*; (input logic [3:0] a [2], input logic k, output logic y, output logic z [2]);\n"
V = {
 'v/v01_mod_not': PK + HD + "  assign y = ~a[k][P-1];\n  assign z[0] = 1'b0;\n  assign z[1] = 1'b0;\nendmodule\n",
 'v/v02_genfor_not': PK + HD + "  for (genvar w = 0; w < 2; w++) begin : g\n    assign z[w] = ~a[w][P-1];\n  end\n  assign y = 1'b0;\nendmodule\n",
 'v/v03_genfor_bare_vs': PK + HD + "  for (genvar w = 0; w < 2; w++) begin : g\n    assign z[w] = a[w][P-1];\n  end\n  assign y = 1'b0;\nendmodule\n",
 'v/v04_genfor_int': PK + HD + "  for (genvar w = 0; w < 2; w++) begin : g\n    assign z[w] = ~a[w][S-1];\n  end\n  assign y = 1'b0;\nendmodule\n",
 'v/v05_genfor_untyped': PK + HD + "  for (genvar w = 0; w < 2; w++) begin : g\n    assign z[w] = ~a[w][U-1];\n  end\n  assign y = 1'b0;\nendmodule\n",
 'v/v06_genfor_qual': PK + HD + "  for (genvar w = 0; w < 2; w++) begin : g\n    assign z[w] = ~a[w][pk::P-1];\n  end\n  assign y = 1'b0;\nendmodule\n",
 'v/v07_genfor_comb_ctl': PK + HD + "  for (genvar w = 0; w < 2; w++) begin : g\n    always_comb z[w] = ~a[w][P-1];\n  end\n  assign y = 1'b0;\nendmodule\n",
 'v/v08_genif_not': PK + HD + "  if (1) begin : g\n    assign y = ~a[k][P-1];\n  end\n  assign z[0] = 1'b0;\n  assign z[1] = 1'b0;\nendmodule\n",
 'v/v09_genfor_eq': PK + HD + "  for (genvar w = 0; w < 2; w++) begin : g\n    assign z[w] = (a[w][P-1] == 1'b1);\n  end\n  assign y = 1'b0;\nendmodule\n",
 'v/v10_genfor_add': PK + HD + "  for (genvar w = 0; w < 2; w++) begin : g\n    assign z[w] = ~a[w][P-3+1];\n  end\n  assign y = 1'b0;\nendmodule\n",
 'v/v11_icache_shape': "package pk; parameter int unsigned ADDR_W = 32; parameter int unsigned IX = 8; parameter int unsigned IC_TAG_SIZE = ADDR_W - IX - 4 + 1; endpackage\nmodule top import pk::*; (input logic [IC_TAG_SIZE-1:0] t [2], output logic [1:0] inv);\n  for (genvar way = 0; way < 2; way++) begin : gen_tag_match\n    assign inv[way] = ~t[way][IC_TAG_SIZE-1];\n  end\nendmodule\n",
 'v/v12_mod_bitsel_ctl': PK + HD + "  logic [3:0] b;\n  assign b = a[0];\n  assign y = ~b[P-1];\n  assign z[0] = 1'b0;\n  assign z[1] = 1'b0;\nendmodule\n",
}
for k, v in V.items():
    d = os.path.join(root, k); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(v)
print(len(V))
V2 = {
 'v/v13_genfor_bitsel': PK + HD + "  logic [3:0] b;\n  assign b = a[0];\n  for (genvar w = 0; w < 2; w++) begin : g\n    assign z[w] = ~b[P-1];\n  end\n  assign y = 1'b0;\nendmodule\n",
 'v/v14_genif_bitsel': PK + HD + "  logic [3:0] b;\n  assign b = a[0];\n  if (1) begin : g\n    assign y = ~b[P-1];\n  end\n  assign z[0] = 1'b0;\n  assign z[1] = 1'b0;\nendmodule\n",
}
for k, v in V2.items():
    d = os.path.join(root, k); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(v)
print(len(V2))
V3 = {
 'v/v15_genfor_bitsel_add': PK + HD + "  logic [3:0] b;\n  assign b = a[0];\n  for (genvar w = 0; w < 2; w++) begin : g\n    assign z[w] = ~b[P-3+1];\n  end\n  assign y = 1'b0;\nendmodule\n",
 'v/v16_genfor_bitsel_int': PK + HD + "  logic [3:0] b;\n  assign b = a[0];\n  for (genvar w = 0; w < 2; w++) begin : g\n    assign z[w] = ~b[S-1];\n  end\n  assign y = 1'b0;\nendmodule\n",
 'v/v17_genfor_bitsel_and': PK + HD + "  logic [3:0] b;\n  assign b = a[0];\n  for (genvar w = 0; w < 2; w++) begin : g\n    assign z[w] = b[P-1] & b[0];\n  end\n  assign y = 1'b0;\nendmodule\n",
 'v/v18_genfor_bitsel_bare': PK + HD + "  logic [3:0] b;\n  assign b = a[0];\n  for (genvar w = 0; w < 2; w++) begin : g\n    assign z[w] = b[P-1];\n  end\n  assign y = 1'b0;\nendmodule\n",
}
for k, v in V3.items():
    d = os.path.join(root, k); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(v)
print(len(V3))
