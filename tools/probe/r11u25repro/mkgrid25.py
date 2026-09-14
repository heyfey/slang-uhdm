#!/usr/bin/env python3
"""r11u25 grid generator — the NON-TERNARY faces of the clone laws.

One dut.sv per arm under $GRID (default /tmp/r11u25_grid).
Faces: F1 the fill-size face (a bare unsized fill as the WHOLE Rhs),
       F2 the dropped-binding face on an expression Rhs carrying an unsized
          constant (DetectUnsizedConstant),
       F3 the non-ternary FOLD face (reduceExpr yields a constant).
Axes:  Rhs shape x scope (module / gen-if / gen-for / nested / gen-case /
       unnamed / child instance / interface) x Lhs kind (own-scope gen-local
       var / net / ancestor gen-local / module var / module net / port /
       namesake / bit-select / part-select / concat / member / unpacked
       element / bare var) x width.
"""
import os, sys

GRID = os.environ.get('GRID', '/tmp/r11u25_grid')

HDR = ("module top #(parameter int K = 9, parameter int PBal = 1)\n"
       "  (input logic [31:0] a, input logic [31:0] b, input logic [4:0] s,\n"
       "   output logic [31:0] o2, output logic [31:0] o3);\n")

ARMS = {}


def genif(body, tail="    assign o2 = lv;\n"):
    return HDR + "  if (1) begin : gb\n" + body + tail + "  end\nendmodule\n"


def gl(rhs, decl="logic [31:0] lv;"):
    """own-scope gen-local variable Lhs in a gen-if"""
    return genif("    %s\n    assign lv = %s;\n" % (decl, rhs))


# ---------------------------------------------------------------- F1 module scope
for t, f in (('0', "'0"), ('1', "'1"), ('x', "'x"), ('z', "'z")):
    ARMS['m0%s_modvar_fill%s' % ({'0': 1, '1': 2, 'x': 3, 'z': 4}[t], t)] = (
        HDR + "  logic [31:0] mv;\n  assign mv = %s;\n  assign o2 = mv;\nendmodule\n" % f)

ARMS['m05_modnet_fill0'] = (
    HDR + "  wire [31:0] mw;\n  assign mw = '0;\n  assign o2 = mw;\nendmodule\n")
ARMS['m06_port_fill0'] = HDR + "  assign o2 = '0;\nendmodule\n"
ARMS['m07_modvar_unsized_op'] = (
    HDR + "  logic [31:0] mv;\n  assign mv = a | '0;\n  assign o2 = mv;\nendmodule\n")
ARMS['m08_modvar_constop'] = (
    HDR + "  logic [31:0] mv;\n  assign mv = 32'd2 + 32'd3;\n  assign o2 = mv;\nendmodule\n")
ARMS['m09_modvar_clog2'] = (
    HDR + "  logic [31:0] mv;\n  assign mv = $clog2(33);\n  assign o2 = mv;\nendmodule\n")
ARMS['m10_modvar_pattern'] = (
    HDR + "  logic [31:0] mv;\n  assign mv = '{default: '0};\n  assign o2 = mv;\nendmodule\n")
ARMS['m11_modvar_fill_in_concat'] = (
    HDR + "  logic [63:0] mv;\n  assign mv = {a, '0};\n  assign o2 = mv[31:0];\nendmodule\n")
ARMS['m12_modvar_bare_var'] = (
    HDR + "  var mv;\n  assign mv = '0;\n  assign o2 = {31'd0, mv};\nendmodule\n")
ARMS['m13_modvar_narrow_fill1'] = (
    HDR + "  logic [7:0] mv;\n  assign mv = '1;\n  assign o2 = {24'd0, mv};\nendmodule\n")
ARMS['m14_modvar_wide_fill1'] = (
    HDR + "  logic [127:0] mv;\n  assign mv = '1;\n  assign o2 = mv[31:0];\nendmodule\n")

# ---------------------------------------------------------------- F1 gen scope
ARMS['p01_genlocal_fill0'] = gl("'0")
ARMS['p02_genlocal_fill1'] = gl("'1")
ARMS['p03_genlocal_fillx'] = gl("'x")
ARMS['p04_genlocal_fillz'] = gl("'z")
ARMS['p05_genlocal_net_fill0'] = genif("    wire [31:0] lv;\n    assign lv = '0;\n")
ARMS['p06_ancestor_genlocal_fill0'] = (
    HDR + "  if (1) begin : g1\n    logic [31:0] ov;\n"
    "    if (1) begin : g2\n      assign ov = '0;\n    end\n"
    "    assign o2 = ov;\n  end\nendmodule\n")
ARMS['p07_modnet_fill0_from_gen'] = (
    HDR + "  wire [31:0] mw;\n  assign o2 = mw;\n"
    "  if (1) begin : gb\n    assign mw = '0;\n  end\nendmodule\n")
ARMS['p08_modvar_fill0_from_gen'] = (
    HDR + "  logic [31:0] mv;\n  assign o2 = mv;\n"
    "  if (1) begin : gb\n    assign mv = '0;\n  end\nendmodule\n")
ARMS['p09_port_fill0_from_gen'] = (
    HDR + "  if (1) begin : gb\n    assign o2 = '0;\n  end\nendmodule\n")
ARMS['p10_genlocal_namesake_fill0'] = (
    HDR + "  logic [3:0] lv;\n  assign o3 = {28'd0, lv};\n"
    "  if (1) begin : gb\n    logic [31:0] lv;\n    assign lv = '0;\n"
    "    assign o2 = lv;\n  end\nendmodule\n")
ARMS['p11_bitsel_lhs_fill0'] = genif(
    "    logic [31:0] lv;\n    assign lv[0] = '0;\n")
ARMS['p12_concat_lhs_fill0'] = genif(
    "    logic [15:0] lv1;\n    logic [15:0] lv2;\n"
    "    assign {lv1, lv2} = '0;\n", "    assign o2 = {lv1, lv2};\n")
ARMS['p13_member_lhs_fill0'] = genif(
    "    typedef struct packed { logic [15:0] m; logic [15:0] n; } st_t;\n"
    "    st_t lv;\n    assign lv.m = '0;\n", "    assign o2 = lv;\n")
ARMS['p14_partsel_lhs_fill0'] = genif(
    "    logic [31:0] lv;\n    assign lv[15:0] = '0;\n")
ARMS['p15_unpacked_elem_lhs_fill0'] = genif(
    "    logic [31:0] lv [0:1];\n    assign lv[0] = '0;\n",
    "    assign o2 = lv[0];\n")
ARMS['p16_iface_genscope_fill0'] = (
    "interface ifc;\n  if (1) begin : gb\n    logic [31:0] lv;\n"
    "    assign lv = '0;\n  end\nendinterface\n"
    "module top(output logic [31:0] o2);\n  ifc u();\n"
    "  assign o2 = u.gb.lv;\nendmodule\n")
ARMS['p17_iface_modscope_fill0'] = (
    "interface ifc;\n  logic [31:0] iv;\n  assign iv = '0;\nendinterface\n"
    "module top(output logic [31:0] o2);\n  ifc u();\n"
    "  assign o2 = u.iv;\nendmodule\n")
ARMS['p18_bare_var_lhs_fill0'] = genif(
    "    var bv;\n    assign bv = '0;\n", "    assign o2 = {31'd0, bv};\n")
ARMS['p19_genfor_fill0'] = (
    HDR + "  for (genvar i = 0; i < 2; i++) begin : gf\n"
    "    logic [31:0] lv;\n    assign lv = '0;\n  end\n"
    "  assign o2 = gf[0].lv;\nendmodule\n")
ARMS['p20_nested3_fill0'] = (
    HDR + "  if (1) begin : n1\n    if (1) begin : n2\n      if (1) begin : n3\n"
    "        logic [31:0] lv;\n        assign lv = '0;\n      end\n    end\n  end\n"
    "  assign o2 = n1.n2.n3.lv;\nendmodule\n")
ARMS['p21_gencase_fill0'] = (
    HDR + "  case (K)\n    9: begin : gc\n      logic [31:0] lv;\n"
    "      assign lv = '0;\n    end\n    default: begin : gd\n"
    "      logic [31:0] lv;\n      assign lv = '1;\n    end\n  endcase\n"
    "  assign o2 = gc.lv;\nendmodule\n")
ARMS['p22_unnamed_genblk_fill0'] = (
    HDR + "  if (1) begin\n    logic [31:0] lv;\n    assign lv = '0;\n  end\n"
    "  assign o2 = 32'd0;\nendmodule\n")
ARMS['p23_child_instance_fill0'] = (
    "module sub(output logic [31:0] q);\n  if (1) begin : gb\n"
    "    logic [31:0] lv;\n    assign lv = '0;\n    assign q = lv;\n  end\n"
    "endmodule\n"
    "module top(output logic [31:0] o2);\n  sub u(.q(o2));\nendmodule\n")
ARMS['p24_genlocal_int_fill0'] = gl("'0", "int lv;")
ARMS['p25_genlocal_wide_fill1'] = genif(
    "    logic [63:0] lv;\n    assign lv = '1;\n", "    assign o2 = lv[31:0];\n")
ARMS['p26_genlocal_narrow_fill1'] = genif(
    "    logic [7:0] lv;\n    assign lv = '1;\n", "    assign o2 = {24'd0, lv};\n")
ARMS['p27_genlocal_scalar_fill1'] = genif(
    "    logic lv;\n    assign lv = '1;\n", "    assign o2 = {31'd0, lv};\n")
ARMS['p28_genlocal_128_fill1'] = genif(
    "    logic [127:0] lv;\n    assign lv = '1;\n", "    assign o2 = lv[31:0];\n")
ARMS['p29_two_cells_one_fill'] = genif(
    "    logic [31:0] lv;\n    logic [31:0] lw;\n"
    "    assign lv = '0;\n    assign lw = a | b;\n",
    "    assign o2 = lv ^ lw;\n")
ARMS['p30_genlocal_delayed_fill'] = genif(
    "    logic [31:0] lv;\n    assign #1 lv = '0;\n")

# ---------------------------------------------------------------- F2 unsized in an expression
ARMS['q01_or_fill0'] = gl("a | '0")
ARMS['q02_concat_fill0'] = genif(
    "    logic [63:0] lv;\n    assign lv = {a, '0};\n",
    "    assign o2 = lv[31:0];\n")
ARMS['q03_xor_fillx'] = gl("a ^ 'x")
ARMS['q04_pattern_fill0'] = gl("'{default: '0}")
ARMS['q05_add_fill1'] = gl("a + '1")
ARMS['q07_unary_fill0'] = gl("~'0")
ARMS['q08_select_or_fill0'] = gl("{28'd0, a[3:0] | '0}")
ARMS['q09_fill0_first_concat'] = genif(
    "    logic [63:0] lv;\n    assign lv = {'0, a};\n",
    "    assign o2 = lv[31:0];\n")
ARMS['q10_net_or_fill0'] = genif("    wire [31:0] lv;\n    assign lv = a | '0;\n")
ARMS['q11_ancestor_or_fill0'] = (
    HDR + "  if (1) begin : g1\n    logic [31:0] ov;\n"
    "    if (1) begin : g2\n      assign ov = a | '0;\n    end\n"
    "    assign o2 = ov;\n  end\nendmodule\n")
ARMS['q12_modnet_or_fill0'] = (
    HDR + "  wire [31:0] mw;\n  assign o2 = mw;\n"
    "  if (1) begin : gb\n    assign mw = a | '0;\n  end\nendmodule\n")
ARMS['q13_ctl_or_sized0'] = gl("a | 32'd0")
ARMS['q14_ctl_wholeref'] = gl("a")
ARMS['q15_ctl_mul'] = gl("$signed(a) * $signed(b)")
ARMS['q16_deep_fill0'] = gl("(a & b) | (a ^ '0)")
ARMS['q17_namesake_or_fill0'] = (
    HDR + "  logic [3:0] lv;\n  assign o3 = {28'd0, lv};\n"
    "  if (1) begin : gb\n    logic [31:0] lv;\n    assign lv = a | '0;\n"
    "    assign o2 = lv;\n  end\nendmodule\n")
ARMS['q18_bitsel_lhs_or_fill0'] = genif(
    "    logic [31:0] lv;\n    assign lv[0] = a[0] | '0;\n")
ARMS['q19_cond_in_op_fill0'] = gl("(a > b) ? a : (b | '0)")
ARMS['q20_repl_fill0'] = genif(
    "    logic [63:0] lv;\n    assign lv = {2{ '0 }};\n",
    "    assign o2 = lv[31:0];\n")

# ---------------------------------------------------------------- F3 the fold face
ARMS['r01_constop'] = gl("32'd2 + 32'd3")
ARMS['r02_clog2'] = gl("$clog2(33)")
ARMS['r03_param_plus'] = gl("K + 1")
ARMS['r04_concat_sized'] = gl("{16'd1, 16'd2}")
ARMS['r05_unsized_add'] = gl("2 + 3")
ARMS['r06_negate'] = gl("-(32'd1)")
ARMS['r07_sized_literal'] = gl("32'd5")
ARMS['r08_paramref'] = gl("K")
ARMS['r09_bits'] = gl("$bits(a)")
ARMS['r10_shift'] = gl("32'd1 << 3")
ARMS['r11_modvar_constop_ctl'] = (
    HDR + "  logic [31:0] mv;\n  assign mv = 32'd2 + 32'd3;\n"
    "  assign o2 = mv;\nendmodule\n")
ARMS['r12_net_constop'] = genif("    wire [31:0] lv;\n    assign lv = 32'd2 + 32'd3;\n")
ARMS['r13_ancestor_constop'] = (
    HDR + "  if (1) begin : g1\n    logic [31:0] ov;\n"
    "    if (1) begin : g2\n      assign ov = 32'd2 + 32'd3;\n    end\n"
    "    assign o2 = ov;\n  end\nendmodule\n")

if __name__ == '__main__':
    os.makedirs(GRID, exist_ok=True)
    for name, src in sorted(ARMS.items()):
        d = os.path.join(GRID, name)
        os.makedirs(d, exist_ok=True)
        with open(os.path.join(d, 'dut.sv'), 'wt') as f:
            f.write(src)
    print('%d arms -> %s' % (len(ARMS), GRID))
