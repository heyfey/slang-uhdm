#!/usr/bin/env python3
# mkgrid115.py: writes grid/<face>/<arm>/dut.sv for the r11u115 golden grid.
#   grid/r : FACE 1 — a folded parameter read under an operation in a generate-scope
#            continuous assignment (operand position x parameter kind x scope).
#   grid/i : FACE 2 — interface port views of interface-ARRAY elements
#            (connection kind x port form x receiver parameters x home scope).
import os
root = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'grid')
A = {}
# ------------------------------------------------------------------ face 1
PK = ("package pk; parameter int unsigned W = $clog2(4); parameter int unsigned WL = 2;"
      " parameter int S = 2; parameter U = 2; parameter logic [3:0] L = 2; endpackage\n")
HDR = ("module top import pk::*; #(parameter int unsigned NUM_FB = 2, parameter int unsigned MW = 2)"
       " (input logic [NUM_FB-1:0] c, input logic s, t, input logic [2:0] q [NUM_FB],"
       " output logic [2:0] y [NUM_FB]);\n")
FN = "  function automatic logic [2:0] f(input logic [31:0] a); return a[2:0]; endfunction\n"
def genfor(e, pre=''):
    return PK + HDR + FN + pre + "  for (genvar fb = 0; fb < NUM_FB; fb++) begin : g\n    assign y[fb] = " + e + ";\n  end\nendmodule\n"
def genif(e):
    e = e.replace('[fb]', '[0]')
    return PK + HDR + FN + "  if (NUM_FB > 1) begin : g\n    assign y[0] = " + e + ";\n  end\n  assign y[1] = '0;\nendmodule\n"
def modsc(e):
    e = e.replace('[fb]', '[0]')
    return PK + HDR + FN + "  assign y[0] = " + e + ";\n  assign y[1] = '0;\nendmodule\n"
def nested(e):
    return PK + HDR + FN + "  for (genvar fb = 0; fb < NUM_FB; fb++) begin : g\n    if (1) begin : h\n      assign y[fb] = " + e + ";\n    end\n  end\nendmodule\n"
POS = {
 'p01_ibex':    "c[fb] ? {{P{1'b0}},s} : (q[fb] + {{P{1'b0}}, t})",
 'p02_replcat': "{{P{1'b0}}, s}",
 'p03_replbare':"{P{s}}",
 'p04_repladd': "q[fb] + {{P{1'b0}}, t}",
 'p05_catelem': "{s, P}",
 'p06_ternarm': "c[fb] ? P : q[fb]",
 'p07_shift':   "q[fb] << P",
 'p08_cmp':     "q[fb] == P",
 'p09_add':     "q[fb] + P",
 'p10_sub':     "q[fb] - P",
 'p11_ufcall':  "f(P)",
 'p12_sysarg':  "q[fb] + $clog2(P)",
 'p13_ternrepl':"c[fb] ? {{P{1'b0}},s} : q[fb]",
}
for k, e in POS.items():
    A[f'r/f/{k}'] = genfor(e.replace('P', 'W'))
for k in ('p01_ibex', 'p02_replcat', 'p03_replbare', 'p05_catelem', 'p06_ternarm', 'p09_add'):
    e = POS[k]
    A[f'r/i/{k}'] = genif(e.replace('P', 'W'))
    A[f'r/m/{k}'] = modsc(e.replace('P', 'W'))
    A[f'r/n/{k}'] = nested(e.replace('P', 'W'))
KIND = {'k01_ius_lit': 'WL', 'k02_int': 'S', 'k03_untyped': 'U', 'k04_logic4': 'L',
        'k05_qual': 'pk::W', 'k06_modhdr': 'MW'}
for k, p in KIND.items():
    for pos in ('p01_ibex', 'p02_replcat', 'p09_add'):
        A[f'r/k/{k}_{pos}'] = genfor(POS[pos].replace('P', p))
for k, p in KIND.items():
    for pos in ('p02_replcat', 'p09_add'):
        A[f'r/mk/{k}_{pos}'] = modsc(POS[pos].replace('P', p))
for k in ('p11_ufcall', 'p12_sysarg', 'p13_ternrepl', 'p07_shift', 'p08_cmp'):
    A[f'r/m/{k}'] = modsc(POS[k].replace('P', 'W'))
    A[f'r/i/{k}'] = genif(POS[k].replace('P', 'W'))
A['r/k/k07_modlp_p01_ibex'] = genfor(POS['p01_ibex'].replace('P', 'ML'), pre="  localparam int unsigned ML = 2;\n")
A['r/k/k08_genlp_p01_ibex'] = (PK + HDR + FN + "  for (genvar fb = 0; fb < NUM_FB; fb++) begin : g\n    localparam int unsigned GL = 2;\n    assign y[fb] = "
                               + POS['p01_ibex'].replace('P', 'GL') + ";\n  end\nendmodule\n")
A['r/k/k09_bodyimp_p01_ibex'] = genfor(POS['p01_ibex'].replace('P', 'W')).replace('module top import pk::*; ', 'module top ').replace(FN, FN + "  import pk::*;\n")
# the ibex shape verbatim (fill_ext_cnt_d), packed 2-D lhs
A['r/x/x01_icache_shape'] = (
 "package pk; parameter int unsigned IC_LINE_BEATS = 4; parameter int unsigned IC_LINE_BEATS_W = $clog2(IC_LINE_BEATS); endpackage\n"
 "module top import pk::*; #(parameter int unsigned NUM_FB = 4) (input logic [NUM_FB-1:0] fill_alloc, input logic fill_spec_done, input logic [NUM_FB-1:0] fill_ext_arb, input logic instr_gnt_i, output logic [NUM_FB-1:0][IC_LINE_BEATS_W:0] fill_ext_cnt_d);\n"
 "  logic [NUM_FB-1:0][IC_LINE_BEATS_W:0] fill_ext_cnt_q;\n  assign fill_ext_cnt_q = fill_ext_cnt_d;\n"
 "  for (genvar fb = 0; fb < NUM_FB; fb++) begin : gen_fbs\n"
 "    assign fill_ext_cnt_d[fb]  = fill_alloc[fb] ?\n                                   {{IC_LINE_BEATS_W{1'b0}},fill_spec_done} :\n"
 "                                   (fill_ext_cnt_q[fb] + {{IC_LINE_BEATS_W{1'b0}},\n                                                          fill_ext_arb[fb] & instr_gnt_i});\n"
 "  end\nendmodule\n")
# ------------------------------------------------------------------ face 2
IF = ("interface itf #(parameter int A = 16, parameter int B = 32, parameter int C = B) ();\n"
      "  logic [A-1:0] a;\n  logic [C-1:0] v;\n  modport m (input a, output v);\nendinterface\n")
def leaf(name, port, recv=''):
    hdr = f" #({recv})" if recv else ''
    use = "  assign p[0].v = '0;\n" if port.endswith('[2]') else "  assign p.v = '0;\n"
    return f"module {name}{hdr} ({port});\n{use}endmodule\n"
# receivers
RM  = lambda recv='': leaf('leaf', 'itf.m p', recv)
RP  = lambda recv='': leaf('leaf', 'itf p', recv)
RAM = lambda recv='': leaf('leaf', 'itf.m p [2]', recv)
RAP = lambda recv='': leaf('leaf', 'itf p [2]', recv)
def top(inst, body, ov='#(8, 32, 64)'):
    return f"module dut ();\n  itf {ov} arr[2] ();\n{body}endmodule\n"
def top1(body, ov='#(8, 32, 64)'):
    return f"module dut ();\n  itf {ov} i ();\n{body}endmodule\n"
R5 = "parameter int A = 5"
R5B = "parameter int A = 5, parameter int B = 40"
A['i/e01_elem_mp_named'] = IF + RM() + top(0, "  leaf u (.p(arr[0]));\n")
A['i/e02_elem_mp_named_recvA'] = IF + RM(R5) + top(0, "  leaf u (.p(arr[0]));\n")
A['i/e03_elem_mp_named_gen'] = IF + RM() + top(0, "  if (1) begin : g\n    leaf u (.p(arr[0]));\n  end\n")
A['i/e04_elem_mp_named_gen_recvA'] = IF + RM(R5) + top(0, "  if (1) begin : g\n    leaf u (.p(arr[0]));\n  end\n")
A['i/e05_elem_mp_named_gen_recvAov'] = IF + RM(R5) + top(0, "  if (1) begin : g\n    leaf #(.A(6)) u (.p(arr[0]));\n  end\n")
A['i/e06_elem_mp_pos'] = IF + RM() + top(0, "  leaf u (arr[0]);\n")
A['i/e07_elem_mp_pos_recvA'] = IF + RM(R5) + top(0, "  leaf u (arr[0]);\n")
A['i/e08_elem_pl_named'] = IF + RP() + top(0, "  leaf u (.p(arr[0]));\n")
A['i/e09_elem_pl_named_recvA'] = IF + RP(R5) + top(0, "  leaf u (.p(arr[0]));\n")
A['i/e10_elem_pl_pos'] = IF + RP() + top(0, "  leaf u (arr[0]);\n")
A['i/e11_elem_mp_named_idx1'] = IF + RM() + top(0, "  leaf u (.p(arr[1]));\n")
A['i/e12_elem_mp_named_ovnamed'] = IF + RM() + top(0, "  leaf u (.p(arr[0]));\n", ov='#(.A(8), .C(64))')
A['i/e13_elem_mp_named_recvB'] = IF + RM("parameter int B = 40") + top(0, "  leaf u (.p(arr[0]));\n")
A['i/e14_elem_mp_named_recvAB_gen'] = IF + RM(R5B) + top(0, "  if (1) begin : g\n    leaf u (.p(arr[0]));\n  end\n")
A['i/e15_elem_mpexpr_named'] = IF + RM() + top(0, "  leaf u (.p(arr[0].m));\n")
A['i/e16_elem_mp_named_genfor'] = IF + RM() + top(0, "  for (genvar k = 0; k < 2; k++) begin : g\n    leaf u (.p(arr[k]));\n  end\n")
# whole-array ports (the pass-111 f4 shapes + receivers)
A['i/w01_arr_mp_named'] = IF + RAM() + top(0, "  leaf u (.p(arr));\n")
A['i/w02_arr_mp_named_recvB'] = IF + RAM("parameter int B = 40") + top(0, "  leaf u (.p(arr));\n")
A['i/w03_arr_mp_named_recvA'] = IF + RAM(R5) + top(0, "  leaf u (.p(arr));\n")
A['i/w04_arr_pl_named'] = IF + RAP() + top(0, "  leaf u (.p(arr));\n")
A['i/w05_arr_pl_pos'] = IF + RAP() + top(0, "  leaf u (arr);\n")
A['i/w06_arr_mp_pos'] = IF + RAM() + top(0, "  leaf u (arr);\n")
# non-array controls
A['i/n01_one_mp_named'] = IF + RM() + top1("  leaf u (.p(i));\n")
A['i/n02_one_mp_pos'] = IF + RM() + top1("  leaf u (i);\n")
A['i/n03_one_pl_named'] = IF + RP() + top1("  leaf u (.p(i));\n")
A['i/n04_one_pl_pos_recvB'] = IF + RP("parameter int B = 40") + top1("  leaf u (i);\n")
A['i/n05_one_mp_named_gen'] = IF + RM() + top1("  if (1) begin : g\n    leaf u (.p(i));\n  end\n")
# receiver-substitution decode (literal vs expression defaults, recv parameter kinds)
IF2 = ("interface itf #(parameter int A = 16, parameter int B = 32, parameter int C = B, parameter int D = A * 2) ();\n"
       "  logic [A-1:0] a;\n  logic [C-1:0] v;\n  logic [D-1:0] d;\n  modport m (input a, d, output v);\nendinterface\n")
A['i/s01_recv_bodylp'] = IF2 + "module leaf (itf.m p);\n  localparam int A = 5;\n  assign p.v = '0;\nendmodule\n" + top(0, "  leaf u (.p(arr[0]));\n")
A['i/s02_recv_bit4'] = IF2 + RM("parameter bit [3:0] A = 5") + top(0, "  leaf u (.p(arr[0]));\n")
A['i/s03_recv_C'] = IF2 + RM("parameter int C = 7") + top(0, "  leaf u (.p(arr[0]));\n")
A['i/s04_recv_A_D'] = IF2 + RM("parameter int A = 5") + top(0, "  leaf u (.p(arr[0]));\n")
A['i/s05_recv_typeA'] = IF2 + RM("parameter type A = logic") + top(0, "  leaf u (.p(arr[0]));\n")
A['i/s06_anc_A'] = IF2 + RM() + "module dut #(parameter int A = 3) ();\n  itf #(8, 32, 64) arr[2] ();\n  leaf u (.p(arr[0]));\nendmodule\n"
A['i/s07_recv_negA'] = IF2 + RM("parameter int A = -3") + top(0, "  leaf u (.p(arr[0]));\n")
A['i/s08_one_mp_named_recvA'] = IF2 + RM("parameter int A = 5") + top1("  leaf u (.p(i));\n")
A['i/s09_untypedif_recvA'] = IF2.replace('parameter int A = 16', 'parameter A = 16') + RM("parameter int A = 5") + top(0, "  leaf u (.p(arr[0]));\n")
A['i/s10_recv_D'] = IF2 + RM("parameter int D = 9") + top(0, "  leaf u (.p(arr[0]));\n")
A['i/s11_arr_mp_recvA_D'] = IF2 + RAM("parameter int A = 5") + top(0, "  leaf u (.p(arr));\n")
A['i/s12_one_pl_pos_recvA_noov'] = IF2 + RP("parameter int A = 5") + "module dut ();\n  itf i ();\n  leaf u (i);\nendmodule\n"
A['i/s13_recv_A_eqdef'] = IF2 + RM("parameter int A = 16") + top(0, "  leaf u (.p(arr[0]));\n")
A['i/s14_recv_A_expr'] = IF2 + RM("parameter int Z = 2, parameter int A = Z + 3") + top(0, "  leaf u (.p(arr[0]));\n")
A['i/s15_recv_A_long'] = IF2 + RM("parameter longint A = 5") + top(0, "  leaf u (.p(arr[0]));\n")
A['i/s16_recv_A_str'] = IF2 + RM('parameter string A = "x"') + top(0, "  leaf u (.p(arr[0]));\n")
A['i/s17_recv_B_opref'] = IF2.replace('parameter int C = B', 'parameter int C = B + 0') + RM("parameter int B = 40") + top(0, "  leaf u (.p(arr[0]));\n")
A['i/s18_recv_B_paren'] = IF2.replace('parameter int C = B', 'parameter int C = (B)') + RM("parameter int B = 40") + top(0, "  leaf u (.p(arr[0]));\n")
IF3 = IF2.replace("  modport m", "  localparam int E = A + 1;\n  localparam int F = 3;\n  logic [E-1:0] e;\n  modport m")
A['i/s19_iflp_op_recvA'] = IF3 + RM("parameter int A = 5") + top(0, "  leaf u (.p(arr[0]));\n")
A['i/s20_iflp_lit_recvF'] = IF3 + RM("parameter int F = 9") + top(0, "  leaf u (.p(arr[0]));\n")
A['i/s21_recv_B_nonarr_pos'] = IF2 + RP("parameter int B = 40") + top1("  leaf u (i);\n")
# named-modport views whose actual lies outside the receiver's instantiating scope
def mid(body):
    return "module mid (itf.m bp);\n" + body + "endmodule\n"
A['i/o01_nmp_gen_recvA'] = IF2 + RM("parameter int A = 5") + top1("  if (1) begin : g\n    leaf u (.p(i));\n  end\n")
A['i/o02_nmp_passport_gen'] = IF2 + RM() + mid("  if (1) begin : g\n    leaf u (.p(bp));\n  end\n") + top1("  mid m (.bp(i));\n")
A['i/o03_nmp_passport_gen_recvA'] = IF2 + RM("parameter int A = 5") + mid("  if (1) begin : g\n    leaf u (.p(bp));\n  end\n") + top1("  mid m (.bp(i));\n")
A['i/o04_nmp_passport_body_ctl'] = IF2 + RM("parameter int A = 5") + mid("  leaf u (.p(bp));\n") + top1("  mid m (.bp(i));\n")
A['i/o05_nmp_samegen_ctl'] = IF2 + RM("parameter int A = 5") + "module dut ();\n  if (1) begin : g\n    itf #(8, 32, 64) i ();\n    leaf u (.p(i));\n  end\nendmodule\n"
A['i/o06_nmp_genfor_recvA'] = IF2 + RM("parameter int A = 5") + top1("  for (genvar k = 0; k < 2; k++) begin : g\n    leaf u (.p(i));\n  end\n")
A['i/o07_nmp_outer_gen'] = IF2 + RM("parameter int A = 5") + "module dut ();\n  if (1) begin : g\n    itf #(8, 32, 64) i ();\n    if (1) begin : h\n      leaf u (.p(i));\n    end\n  end\nendmodule\n"
A['i/o08_nmp_mpexpr_gen'] = IF2 + RM("parameter int A = 5") + top1("  if (1) begin : g\n    leaf u (.p(i.m));\n  end\n")
# FACE 1c: a bare typed package parameter as a var_select element index (ibex_icache.sv:766)
VH = ("module top import pk::*; #(parameter int unsigned NUM_FB = 2) (input logic [NUM_FB-1:0][3:0] q2,"
      " input logic s, output logic y [NUM_FB], output logic z);\n")
def vs(body): return PK + VH + body + "endmodule\n"
A['r/v/v01_mod_bare'] = vs("  assign z = q2[1][W];\n  assign y[0] = s;\n  assign y[1] = s;\n")
A['r/v/v02_genfor_bare'] = vs("  for (genvar fb = 0; fb < NUM_FB; fb++) begin : g\n    assign y[fb] = q2[fb][W];\n  end\n  assign z = s;\n")
A['r/v/v03_genfor_underop'] = vs("  for (genvar fb = 0; fb < NUM_FB; fb++) begin : g\n    assign y[fb] = q2[fb][W] | s;\n  end\n  assign z = s;\n")
A['r/v/v04_genif_underop'] = vs("  if (NUM_FB > 1) begin : g\n    assign y[0] = q2[0][W] | s;\n  end\n  assign y[1] = s;\n  assign z = s;\n")
A['r/v/v05_comb_ctl'] = vs("  always_comb z = q2[1][W];\n  assign y[0] = s;\n  assign y[1] = s;\n")
A['r/v/v06_genfor_untyped'] = vs("  for (genvar fb = 0; fb < NUM_FB; fb++) begin : g\n    assign y[fb] = q2[fb][U] | s;\n  end\n  assign z = s;\n")
A['r/v/v07_genfor_qual'] = vs("  for (genvar fb = 0; fb < NUM_FB; fb++) begin : g\n    assign y[fb] = q2[fb][pk::W] | s;\n  end\n  assign z = s;\n")
A['r/v/v08_genfor_int'] = vs("  for (genvar fb = 0; fb < NUM_FB; fb++) begin : g\n    assign y[fb] = q2[fb][S] | s;\n  end\n  assign z = s;\n")
A['r/v/v09_mod_underop'] = vs("  assign z = q2[1][W] | s;\n  assign y[0] = s;\n  assign y[1] = s;\n")
A['r/v/v10_genfor_modparam_ctl'] = vs("  localparam int unsigned ML = 2;\n  for (genvar fb = 0; fb < NUM_FB; fb++) begin : g\n    assign y[fb] = q2[fb][ML] | s;\n  end\n  assign z = s;\n")
A['r/v/v11_genfor_ternary'] = vs("  for (genvar fb = 0; fb < NUM_FB; fb++) begin : g\n    assign y[fb] = s ? q2[fb][W] : 1'b0;\n  end\n  assign z = s;\n")
A['r/v/v12_genfor_1d_bitsel_ctl'] = vs("  logic [3:0] q1;\n  assign q1 = q2[0];\n  for (genvar fb = 0; fb < NUM_FB; fb++) begin : g\n    assign y[fb] = q1[W] | s;\n  end\n  assign z = s;\n")
A['r/v/v13_genfor_lhs_ctl'] = vs("  logic [NUM_FB-1:0][3:0] o2;\n  for (genvar fb = 0; fb < NUM_FB; fb++) begin : g\n    assign o2[fb][W] = s;\n    assign y[fb] = o2[fb][0];\n  end\n  assign z = s;\n")
A['r/v/v14_mod_lhs'] = vs("  logic [NUM_FB-1:0][3:0] o2;\n  assign o2[1][W] = s;\n  assign z = o2[1][0];\n  assign y[0] = s;\n  assign y[1] = s;\n")
for k, v in A.items():
    d = os.path.join(root, k); os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, 'dut.sv'), 'w') as f: f.write(v)
print(len(A), 'arms')
