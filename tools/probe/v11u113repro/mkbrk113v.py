import os
A={}
pk=lambda t,init='5',extra='': f"package pk; parameter {t} P = {init}; {extra}endpackage\n"
M=lambda decls,imp="import pk::*; ",ports="input logic [7:0] i, output logic [7:0] o": f"module top {imp}({ports});\n{decls}endmodule\n"
# face 1
A['f1/a01_func_local']=pk('int unsigned')+M("  function automatic logic [7:0] f(input logic [7:0] a);\n    logic [P:0] v;\n    v = a[5:0];\n    return {2'b0, v};\n  endfunction\n  assign o = f(i);\n")
A['f1/a02_iface']=pk('int unsigned')+"interface ifc import pk::*; ();\n  logic [P:0] x;\nendinterface\nmodule top (input logic [7:0] i, output logic [7:0] o);\n  ifc u();\n  assign u.x = i[5:0];\n  assign o = u.x;\nendmodule\n"
A['f1/a03_named_block']=pk('int unsigned')+M("  always_comb begin : b\n    logic [P:0] v;\n    v = i[5:0];\n    o = v;\n  end\n")
A['f1/a04_pkg_var']=pk('int unsigned', extra="logic [P:0] pv; ")+M("  assign pv = i[5:0];\n  assign o = pv;\n")
A['f1/a05_bit1']=pk('bit','1')+M("  logic [P:0] x;\n  assign x = i[1:0];\n  assign o = x;\n")
A['f1/a06_clog2']=pk('int unsigned','$clog2(64)')+M("  logic [P:0] x;\n  assign x = i[6:0];\n  assign o = x;\n")
A['f1/a07_pow']=pk('int','2**2')+M("  logic [P:0] x;\n  assign x = i[4:0];\n  assign o = x;\n")
A['f1/a08_div']=pk('int','10/2')+M("  logic [P:0] x;\n  assign x = i[5:0];\n  assign o = x;\n")
A['f1/a09_genfor_lp']="module top (input logic [7:0] i, output logic [7:0] o [2]);\n  for (genvar k = 0; k < 2; k++) begin : g\n    localparam int unsigned P = k + 3;\n    logic [P:0] x;\n    assign x = i[P:0];\n    assign o[k] = x;\n  end\nendmodule\n"
A['f1/a10_pkg_ref_other']="package pk; parameter int unsigned R = 3; parameter int unsigned P = R * 2; endpackage\n"+M("  logic [P:0] x;\n  assign x = i[6:0];\n  assign o = x;\n")
A['f1/a11_shortint']=pk('shortint','5')+M("  logic [P:0] x;\n  assign x = i[5:0];\n  assign o = x;\n")
A['f1/a12_unsized_tick']=pk('int unsigned',"'1 & 5")+M("  logic [P:0] x;\n  assign x = i[5:0];\n  assign o = x;\n")
A['f1/a13_child_overridden_mod_uses_pkg']=pk('int unsigned')+"module c import pk::*; #(parameter int W = 2) (input logic [7:0] i, output logic [7:0] o);\n  logic [P:0] x;\n  logic [W:0] y;\n  assign x = i[5:0];\n  assign y = i[W:0];\n  assign o = x ^ y;\nendmodule\nmodule top (input logic [7:0] i, output logic [7:0] o);\n  c #(.W(3)) u (.i(i), .o(o));\nendmodule\n"
A['f1/a14_param_decl_range']=pk('int unsigned')+M("  localparam logic [P:0] L = '1;\n  assign o = L;\n")
A['f1/a15_task_local']=pk('int unsigned')+M("  task automatic t(output logic [7:0] r);\n    logic [P:0] v;\n    v = '1;\n    r = v;\n  endtask\n  always_comb t(o);\n")
A['f1/a16_genif_localparam_int']="module top (input logic [7:0] i, output logic [7:0] o);\n  if (1) begin : g\n    localparam int P = 5;\n    logic [P:0] x;\n    assign x = i[5:0];\n    assign o = x;\n  end\nendmodule\n"
A['f1/a17_nested_gen_pkg']=pk('int unsigned')+M("  for (genvar k = 0; k < 1; k++) begin : g\n    if (1) begin : h\n      wire [P:0] x;\n      assign x = i[5:0];\n      assign o = x;\n    end\n  end\n")
A['f1/a18_negative_bound']=pk('int','-2')+M("  logic [5:P] x;\n  assign x = i;\n  assign o = x;\n")
A['f1/a19_modport_ports']=pk('int unsigned')+"module c import pk::*; (input wire [P:0] i, output var logic [P:0] o);\n  assign o = i;\nendmodule\nmodule top (input logic [7:0] i, output logic [7:0] o);\n  c u (.i(i[5:0]), .o(o[5:0]));\n  assign o[7:6] = '0;\nendmodule\n"
A['f1/a20_long']=pk('longint unsigned','5')+M("  logic [P:0] x;\n  assign x = i[5:0];\n  assign o = x;\n")
# face 2
TP="module top #(parameter type idx_t = logic [1:0]) (input logic a, output logic [1:0] y);\n"
A['f2/t01_pkg_lptype']="package pk; localparam type idx_t = logic [1:0]; endpackage\nmodule top import pk::*; (input logic a, output logic [1:0] y);\n  if (1) begin : g\n    assign y = idx_t'(a);\n  end\nendmodule\n"
A['f2/t02_gen_local_lptype']="module top (input logic a, output logic [1:0] y);\n  if (1) begin : g\n    localparam type idx_t = logic [1:0];\n    assign y = idx_t'(a);\n  end\nendmodule\n"
A['f2/t03_iface_tp']="interface ifc #(parameter type idx_t = logic [1:0]) (input logic a);\n  logic [1:0] y;\n  if (1) begin : g\n    assign y = idx_t'(a);\n  end\nendinterface\nmodule top (input logic a, output logic [1:0] y);\n  ifc u(.a(a));\n  assign y = u.y;\nendmodule\n"
A['f2/t04_paren']=TP+"  if (1) begin : g\n    assign y = (idx_t'(a));\n  end\nendmodule\n"
A['f2/t05_genfor_lptype_inner']="module top (input logic a, output logic [1:0] y [2]);\n  for (genvar k = 0; k < 2; k++) begin : g\n    localparam type idx_t = logic [1:0];\n    assign y[k] = idx_t'(a);\n  end\nendmodule\n"
A['f2/t06_pkg_lptype_qual']="package pk; localparam type idx_t = logic [1:0]; endpackage\nmodule top (input logic a, output logic [1:0] y);\n  if (1) begin : g\n    assign y = pk::idx_t'(a);\n  end\nendmodule\n"
A['f2/t07_casedgen']=TP+"  case (1)\n    1: begin : g\n      assign y = idx_t'(a);\n    end\n  endcase\nendmodule\n"
A['f2/t08_unit_lptype']="localparam type idx_t = logic [1:0];\nmodule top (input logic a, output logic [1:0] y);\n  if (1) begin : g\n    assign y = idx_t'(a);\n  end\nendmodule\n"
# face 3
A['f3/e01_explicit_vals']="module m(output logic [3:0] o);\n  typedef struct packed { enum logic [1:0] {A=1, B=3} e; logic [1:0] b; } s_t;\n  s_t x;\n  assign x = '0;\n  assign o = x;\nendmodule\n"
A['f3/e02_unpacked_struct']="module m(output logic [1:0] o);\n  typedef struct { enum logic [1:0] {A, B, C} e; logic [1:0] b; } s_t;\n  s_t x;\n  assign x.e = B;\n  assign x.b = '0;\n  assign o = x.e;\nendmodule\n"
A['f3/e03_func_arg']="module m(output logic [3:0] o);\n  typedef struct packed { enum logic [1:0] {A, B, C} e; logic [1:0] b; } s_t;\n  function automatic s_t f(input logic [1:0] v);\n    s_t r;\n    r.e = C;\n    r.b = v;\n    return r;\n  endfunction\n  assign o = f(2'b1);\nendmodule\n"
A['f3/e04_two_enum_members']="module m(output logic [3:0] o);\n  typedef struct packed { enum logic [1:0] {A, B} e; enum logic [1:0] {C, D} f; } s_t;\n  s_t x;\n  assign x = '0;\n  assign o = x;\nendmodule\n"
A['f3/e05_pkg_used_in_two_mods']="package pk; typedef struct packed { enum logic [1:0] {A, B, C} e; logic [1:0] b; } s_t; endpackage\nmodule c(output pk::s_t o);\n  assign o.e = pk::B;\n  assign o.b = '0;\nendmodule\nmodule m(output logic [3:0] o);\n  pk::s_t x;\n  c u(.o(x));\n  assign o = x;\nendmodule\n"
A['f3/e06_enum_range_base']="module m(output logic [3:0] o);\n  typedef struct packed { enum bit [2:0] {A, B, C} e; logic b; } s_t;\n  s_t x;\n  assign x = '0;\n  assign o = x;\nendmodule\n"
A['f3/e07_class_member']="package pk; class C; typedef struct packed { enum logic [1:0] {A, B} e; logic b; } s_t; s_t v; endclass endpackage\nmodule m(output logic o);\n  assign o = 1'b0;\nendmodule\n"
# face 4
P=lambda body: f"module m(input logic clk, rst, a, b, c);\n  property p1;\n    @(posedge clk) {body};\n  endproperty\n  a1: assert property (p1);\nendmodule\n"
A['f4/r01_seqdecl']="module m(input logic clk, rst, a, b, c);\n  sequence s1;\n    b[*1:3];\n  endsequence\n  a1: assert property (@(posedge clk) a |-> s1);\nendmodule\n"
A['f4/r02_formal']="module m(input logic clk, rst, a, b, c);\n  property p1(x, y);\n    @(posedge clk) x |-> y[*1:3];\n  endproperty\n  a1: assert property (p1(a, b));\nendmodule\n"
A['f4/r03_not']=P("not (a ##1 b[*1:2])")
A['f4/r04_or']=P("a |-> (b[*1:2] or c[=1:2])")
A['f4/r05_param_bound']="module m #(parameter int N = 3) (input logic clk, rst, a, b, c);\n  property p1;\n    @(posedge clk) a |-> b[*1:N];\n  endproperty\n  a1: assert property (p1);\nendmodule\n"
A['f4/r06_nested_rep']=P("a |-> (b ##1 c)[*1:2]")
A['f4/r07_eq_inf']=P("a |-> b[=1:$] ##1 c")
A['f4/r08_goto_inf']=P("a |-> b[->1:$]")
A['f4/r09_two_props']="module m(input logic clk, rst, a, b, c);\n  property p1;\n    @(posedge clk) a |-> b[*1:3];\n  endproperty\n  property p2;\n    @(posedge clk) c |-> b[*2:4];\n  endproperty\n  a1: assert property (p1);\n  a2: cover property (p2);\nendmodule\n"
A['f4/r10_based_bound']=P("a |-> b[*1:2'd3]")
# face 5
PK="package pk; parameter int unsigned P = 4; endpackage\n"
HD="module top import pk::*; (input logic [3:0] a [2], input logic [3:0] a3 [2][2], input logic k, output logic y, output logic [3:0] q [2]);\n"
A['f5/v01_lhs_vs_mod']=PK+HD+"  assign q[k][P-1] = a[0][0];\n  assign y = 1'b0;\nendmodule\n"
A['f5/v02_lhs_vs_gen']=PK+HD+"  for (genvar w = 0; w < 2; w++) begin : g\n    assign q[w][P-1] = a[w][0];\n  end\n  assign y = 1'b0;\nendmodule\n"
A['f5/v03_3d_gen']=PK+HD+"  for (genvar w = 0; w < 2; w++) begin : g\n    assign q[w] = {3'b0, ~a3[w][0][P-1]};\n  end\n  assign y = 1'b0;\nendmodule\n"
A['f5/v04_ternary_gen']=PK+HD+"  for (genvar w = 0; w < 2; w++) begin : g\n    assign q[w] = k ? {3'b0, a[w][P-1]} : 4'b0;\n  end\n  assign y = 1'b0;\nendmodule\n"
A['f5/v05_idx_mult']=PK+HD+"  for (genvar w = 0; w < 2; w++) begin : g\n    assign q[w] = {3'b0, ~a[w][P/2]};\n  end\n  assign y = 1'b0;\nendmodule\n"
A['f5/v06_netdecl_gen']=PK+HD+"  for (genvar w = 0; w < 2; w++) begin : g\n    wire t = ~a[w][P-1];\n    assign q[w] = {3'b0, t};\n  end\n  assign y = 1'b0;\nendmodule\n"
for k,v in A.items():
    d=os.path.join(os.path.dirname(os.path.abspath(__file__)),'grid',k); os.makedirs(d,exist_ok=True); open(os.path.join(d,'dut.sv'),'w').write(v)
print(len(A))
