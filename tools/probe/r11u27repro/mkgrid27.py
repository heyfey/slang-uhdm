#!/usr/bin/env python3
"""r11u27 grid — FACE 3: the NON-TERNARY cont-assign fold's three encodings."""
import os, sys
GRID = os.environ.get('GRID', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'grid'))
HDR = ("module top #(parameter int K = 9, parameter int PBal = 1)\n"
       "  (input logic [31:0] a, input logic [31:0] b, input logic [4:0] s,\n"
       "   output logic [31:0] o2, output logic [31:0] o3);\n")
ARMS = {}
def genif(body, tail="    assign o2 = lv;\n"):
    return HDR + "  if (1) begin : gb\n" + body + tail + "  end\nendmodule\n"
def gl(rhs, decl="logic [31:0] lv;"):
    """UNBOUND: own-scope gen-local variable Lhs in a gen-if"""
    return genif("    %s\n    assign lv = %s;\n" % (decl, rhs))
def mv(rhs, decl="logic [31:0] mv;", tail="  assign o2 = mv;\n"):
    """BOUND: module-scope variable Lhs"""
    return HDR + "  %s\n  assign mv = %s;\n%sendmodule\n" % (decl, rhs, tail)

# ============ U: UNBOUND (own-scope gen-local), the 13 recorded face-3 arms
ARMS['u01_constop']      = gl("32'd2 + 32'd3")
ARMS['u02_clog2']        = gl("$clog2(33)")
ARMS['u03_param_plus']   = gl("K + 1")
ARMS['u04_concat_sized'] = gl("{16'd1, 16'd2}")
ARMS['u05_unsized_add']  = gl("2 + 3")
ARMS['u06_negate']       = gl("-(32'd1)")
ARMS['u07_sized_literal']= gl("32'd5")
ARMS['u08_paramref']     = gl("K")
ARMS['u09_bits']         = gl("$bits(a)")
ARMS['u10_shift']        = gl("32'd1 << 3")
ARMS['u12_net_constop']  = genif("    wire [31:0] lv;\n    assign lv = 32'd2 + 32'd3;\n")
ARMS['u13_ancestor_constop'] = (
    HDR + "  if (1) begin : g1\n    logic [31:0] ov;\n"
    "    if (1) begin : g2\n      assign ov = 32'd2 + 32'd3;\n    end\n"
    "    assign o2 = ov;\n  end\nendmodule\n")
# ============ M: BOUND (module scope) — r11 / m08 / m14 and the same ladder
ARMS['m01_constop']      = mv("32'd2 + 32'd3")
ARMS['m02_clog2']        = mv("$clog2(33)")
ARMS['m03_param_plus']   = mv("K + 1")
ARMS['m04_concat_sized'] = mv("{16'd1, 16'd2}")
ARMS['m05_unsized_add']  = mv("2 + 3")
ARMS['m06_negate']       = mv("-(32'd1)")
ARMS['m07_sized_literal']= mv("32'd5")
ARMS['m08_paramref']     = mv("K")
ARMS['m09_bits']         = mv("$bits(a)")
ARMS['m10_shift']        = mv("32'd1 << 3")
ARMS['m14_wide_fill1']   = (HDR + "  logic [127:0] mv;\n  assign mv = '1;\n"
                            "  assign o2 = mv[31:0];\nendmodule\n")
# ============ operand-shape ladder (UNBOUND + BOUND)
LADDER = {
  'a01_sized_sub':     "32'd7 - 32'd3",
  'a02_sized_mul':     "32'd2 * 32'd3",
  'a03_sized_div':     "32'd7 / 32'd2",
  'a04_sized_mod':     "32'd7 % 32'd2",
  'a05_sized_and':     "32'd6 & 32'd3",
  'a06_sized_or':      "32'd6 | 32'd3",
  'a07_sized_xor':     "32'd6 ^ 32'd3",
  'a08_unsized_sub':   "7 - 3",
  'a09_mixed_add':     "32'd2 + 3",
  'a10_mixed_add_rev': "2 + 32'd3",
  'a11_hex_add':       "32'h2 + 32'h3",
  'a12_bin_add':       "32'b10 + 32'b11",
  'a13_signed_add':    "32'sd2 + 32'sd3",
  'a14_sized_neg':     "32'd2 - 32'd3",
  'a15_unsized_neg':   "2 - 3",
  'a16_param_param':   "K + K",
  'a17_param_sized':   "K + 32'd1",
  'a18_lshift_sized':  "32'd2 << 32'd1",
  'a19_rshift':        "32'd8 >> 32'd1",
  'a20_cmp':           "32'd2 < 32'd3",
  'a21_logand':        "32'd2 && 32'd3",
  'a22_unary_not':     "!32'd0",
  'a23_unary_bitneg':  "~32'd0",
  'a24_concat_unsized':"{16'd1, 2}",
  'a25_concat3':       "{8'd1, 8'd2, 16'd3}",
  'a26_repl':          "{4{8'h0f}}",
  'a27_concat_param':  "{16'd1, K[15:0]}",
  'a28_nested_add':    "(32'd1 + 32'd2) + 32'd3",
  'a29_nested_mix':    "(2 + 3) + 32'd4",
  'a30_narrow_add':    "8'd2 + 8'd3",
  'a31_wide_add':      "64'd2 + 64'd3",
  'a32_add_zero':      "32'd0 + 32'd0",
  'a33_paren_literal':  "(32'd5)",
  'a34_unsized_literal':"5",
  'a35_bits_plus':      "$bits(a) + 1",
  'a36_clog2_plus':     "$clog2(33) + 32'd1",
  'a37_sized_add_1bit':  "1'b1 + 1'b0",
  'a38_wide128':        "128'd2 + 128'd3",
  'a39_cast':           "int'(7)",
  'a40_enumref':        "32'd2 + 32'd3",   # placeholder, redefined below
}
for k, r in LADDER.items():
    ARMS['U' + k] = gl(r)
    ARMS['M' + k] = mv(r)
del ARMS['Ua40_enumref']; del ARMS['Ma40_enumref']

# ============ width axis on the winning shapes (bound + unbound)
for w, tag in ((1, 'w01'), (8, 'w08'), (64, 'w64'), (128, 'w128')):
    d = "logic [%d:0] lv;" % (w - 1)
    dm = "logic [%d:0] mv;" % (w - 1)
    tl = "    assign o2 = {%d'd0, lv};\n" % (32 - w) if w < 32 else "    assign o2 = lv[31:0];\n"
    ARMS['U%s_constop' % tag] = genif("    %s\n    assign lv = 32'd2 + 32'd3;\n" % d, tl)
    tm = "  assign o2 = {%d'd0, mv};\n" % (32 - w) if w < 32 else "  assign o2 = mv[31:0];\n"
    ARMS['M%s_constop' % tag] = mv("32'd2 + 32'd3", dm, tm)
    ARMS['U%s_concat' % tag] = genif("    %s\n    assign lv = {16'd1, 16'd2};\n" % d, tl)
    ARMS['M%s_concat' % tag] = mv("{16'd1, 16'd2}", dm, tm)
    ARMS['U%s_unsized' % tag] = genif("    %s\n    assign lv = 2 + 3;\n" % d, tl)
    ARMS['M%s_unsized' % tag] = mv("2 + 3", dm, tm)

# ============ scope axis (all on the 32'd2+32'd3 shape)
ARMS['s01_genfor'] = (HDR + "  for (genvar gi = 0; gi < 1; gi++) begin : gf\n"
    "    logic [31:0] lv;\n    assign lv = 32'd2 + 32'd3;\n    assign o2 = lv;\n  end\nendmodule\n")
ARMS['s02_nested'] = (HDR + "  if (1) begin : g1\n    if (1) begin : g2\n"
    "      logic [31:0] lv;\n      assign lv = 32'd2 + 32'd3;\n      assign o2 = lv;\n"
    "    end\n  end\nendmodule\n")
ARMS['s03_gencase'] = (HDR + "  case (PBal)\n    1: begin : gc\n"
    "      logic [31:0] lv;\n      assign lv = 32'd2 + 32'd3;\n      assign o2 = lv;\n"
    "    end\n  endcase\nendmodule\n")
ARMS['s04_unnamed'] = (HDR + "  if (1) begin\n"
    "    logic [31:0] lv;\n    assign lv = 32'd2 + 32'd3;\n    assign o2 = lv;\n  end\nendmodule\n")
ARMS['s05_child'] = ("module sub(output logic [31:0] o);\n  if (1) begin : gb\n"
    "    logic [31:0] lv;\n    assign lv = 32'd2 + 32'd3;\n    assign o = lv;\n  end\nendmodule\n"
    + HDR + "  sub u0(.o(o2));\nendmodule\n")
ARMS['s06_child_mod'] = ("module sub(output logic [31:0] o);\n  logic [31:0] mv;\n"
    "  assign mv = 32'd2 + 32'd3;\n  assign o = mv;\nendmodule\n"
    + HDR + "  sub u0(.o(o2));\nendmodule\n")
ARMS['s07_iface_gen'] = ("interface iff;\n  if (1) begin : gb\n    logic [31:0] lv;\n"
    "    assign lv = 32'd2 + 32'd3;\n  end\nendinterface\n" + HDR + "  iff i0();\n"
    "  assign o2 = 32'd0;\nendmodule\n")
ARMS['s08_iface_mod'] = ("interface iff;\n  logic [31:0] mv;\n"
    "  assign mv = 32'd2 + 32'd3;\nendinterface\n" + HDR + "  iff i0();\n"
    "  assign o2 = 32'd0;\nendmodule\n")
ARMS['s09_modnet_from_gen'] = (HDR + "  wire [31:0] mw;\n  assign o2 = mw;\n"
    "  if (1) begin : gb\n    assign mw = 32'd2 + 32'd3;\n  end\nendmodule\n")
ARMS['s10_port_from_gen'] = (HDR + "  if (1) begin : gb\n    assign o2 = 32'd2 + 32'd3;\n  end\nendmodule\n")
ARMS['s11_namesake'] = (HDR + "  logic [3:0] lv;\n  assign o3 = {28'd0, lv};\n"
    "  if (1) begin : gb\n    logic [31:0] lv;\n    assign lv = 32'd2 + 32'd3;\n"
    "    assign o2 = lv;\n  end\nendmodule\n")
ARMS['s12_modnet'] = (HDR + "  wire [31:0] mw;\n  assign mw = 32'd2 + 32'd3;\n"
    "  assign o2 = mw;\nendmodule\n")
ARMS['s13_port'] = (HDR + "  assign o2 = 32'd2 + 32'd3;\nendmodule\n")
ARMS['s14_bitsel_lhs'] = genif("    logic [31:0] lv;\n    assign lv[0] = 32'd2 + 32'd3;\n")
ARMS['s15_partsel_lhs'] = genif("    logic [31:0] lv;\n    assign lv[3:0] = 32'd2 + 32'd3;\n")
ARMS['s16_barevar'] = genif("    var lv;\n    assign lv = 32'd2 + 32'd3;\n", "    assign o2 = {31'd0, lv};\n")
ARMS['s17_delayed'] = genif("    logic [31:0] lv;\n    assign #1 lv = 32'd2 + 32'd3;\n")
ARMS['s18_enum'] = (HDR + "  typedef enum logic [31:0] { EA = 32'd2, EB = 32'd3 } e_t;\n"
    "  if (1) begin : gb\n    logic [31:0] lv;\n    assign lv = EA + EB;\n"
    "    assign o2 = lv;\n  end\nendmodule\n")
ARMS['s19_enum_mod'] = (HDR + "  typedef enum logic [31:0] { EA = 32'd2, EB = 32'd3 } e_t;\n"
    "  logic [31:0] mv;\n  assign mv = EA + EB;\n  assign o2 = mv;\nendmodule\n")
ARMS['s20_localparam'] = (HDR + "  localparam int LP = 4;\n  logic [31:0] mv;\n"
    "  assign mv = LP + 32'd1;\n  assign o2 = mv;\nendmodule\n")
ARMS['s21_signed_lhs'] = (HDR + "  logic signed [31:0] mv;\n  assign mv = 32'd2 - 32'd3;\n"
    "  assign o2 = mv;\nendmodule\n")
ARMS['s22_signed_lhs_gen'] = genif("    logic signed [31:0] lv;\n    assign lv = 32'd2 - 32'd3;\n")
ARMS['s23_int_lhs'] = (HDR + "  int mv;\n  assign mv = 32'd2 + 32'd3;\n  assign o2 = mv;\nendmodule\n")
ARMS['s24_int_lhs_gen'] = genif("    int lv;\n    assign lv = 32'd2 + 32'd3;\n")
ARMS['s25_twocells'] = genif("    logic [31:0] lv;\n    logic [31:0] lv2;\n"
    "    assign lv = 32'd2 + 32'd3;\n    assign lv2 = a | b;\n", "    assign o2 = lv ^ lv2;\n")

def main():
    os.makedirs(GRID, exist_ok=True)
    for k, v in sorted(ARMS.items()):
        d = os.path.join(GRID, k)
        os.makedirs(d, exist_ok=True)
        open(os.path.join(d, 'dut.sv'), 'w').write(v)
    print("ARMS=%d GRID=%s" % (len(ARMS), GRID))

main()
