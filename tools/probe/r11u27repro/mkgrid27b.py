#!/usr/bin/env python3
"""r11u27 grid, part 2 — the PARAMETER-operand encoding, the >64 branch, views."""
import os
GRID = os.environ.get('GRID', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'grid'))
ARMS = {}
def mod(params, body, ports="(input logic [31:0] a, output logic [31:0] o2)"):
    return "module top %s\n  %s\n%sendmodule\n" % (params, ports, body)

# ---- parameter operand encodings (BOUND, module scope) x (UNBOUND, gen scope)
PDECL = {
  'p01_int9'    : "parameter int P = 9;",
  'p02_int_neg' : "parameter int P = -3;",
  'p03_untyped9': "parameter P = 9;",
  'p04_hex'     : "parameter P = 32'hA;",
  'p05_sized_d' : "parameter P = 32'd9;",
  'p06_bin'     : "parameter P = 4'b1010;",
  'p07_logic'   : "parameter logic [7:0] P = 8'd9;",
  'p08_lp_int'  : "localparam int P = 9;",
  'p09_lp_plain': "localparam P = 9;",
  'p10_byte'    : "parameter byte P = 9;",
}
for k, d in PDECL.items():
    ARMS['P' + k + '_M'] = ("module top(input logic [31:0] a, output logic [31:0] o2);\n"
        "  %s\n  logic [31:0] mv;\n  assign mv = P + 32'd1;\n  assign o2 = mv;\nendmodule\n" % d)
    ARMS['P' + k + '_U'] = ("module top(input logic [31:0] a, output logic [31:0] o2);\n"
        "  %s\n  if (1) begin : gb\n    logic [31:0] lv;\n"
        "    assign lv = P + 32'd1;\n    assign o2 = lv;\n  end\nendmodule\n" % d)
    ARMS['P' + k + '_Mp'] = ("module top(input logic [31:0] a, output logic [31:0] o2);\n"
        "  %s\n  logic [31:0] mv;\n  assign mv = P + P;\n  assign o2 = mv;\nendmodule\n" % d)

# ---- the >64 branch and wide arithmetic
ARMS['W01_add128_to128'] = ("module top(output logic [127:0] o);\n"
    "  logic [127:0] mv;\n  assign mv = 128'd2 + 128'd3;\n  assign o = mv;\nendmodule\n")
ARMS['W02_add128_hex'] = ("module top(output logic [127:0] o);\n"
    "  logic [127:0] mv;\n  assign mv = 128'h2 + 128'h3;\n  assign o = mv;\nendmodule\n")
ARMS['W03_bigliteral'] = ("module top(output logic [127:0] o);\n"
    "  logic [127:0] mv;\n  assign mv = 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF;\n"
    "  assign o = mv;\nendmodule\n")
ARMS['W04_add_overflow64'] = ("module top(output logic [63:0] o);\n"
    "  logic [63:0] mv;\n  assign mv = 64'hFFFFFFFFFFFFFFFF + 64'd1;\n  assign o = mv;\nendmodule\n")
ARMS['W05_concat72'] = ("module top(output logic [71:0] o);\n"
    "  logic [71:0] mv;\n  assign mv = {8'hFF, 64'd3};\n  assign o = mv;\nendmodule\n")
ARMS['W06_u_add128'] = ("module top(output logic [127:0] o);\n"
    "  if (1) begin : gb\n    logic [127:0] lv;\n    assign lv = 128'd2 + 128'd3;\n"
    "    assign o = lv;\n  end\nendmodule\n")
ARMS['W07_u_bigliteral'] = ("module top(output logic [127:0] o);\n"
    "  if (1) begin : gb\n    logic [127:0] lv;\n"
    "    assign lv = 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF;\n"
    "    assign o = lv;\n  end\nendmodule\n")
ARMS['W08_modfill1_64'] = ("module top(output logic [63:0] o);\n"
    "  logic [63:0] mv;\n  assign mv = '1;\n  assign o = mv;\nendmodule\n")
ARMS['W09_modfill1_65'] = ("module top(output logic [64:0] o);\n"
    "  logic [64:0] mv;\n  assign mv = '1;\n  assign o = mv;\nendmodule\n")
ARMS['W10_modfill1_72'] = ("module top(output logic [71:0] o);\n"
    "  logic [71:0] mv;\n  assign mv = '1;\n  assign o = mv;\nendmodule\n")
ARMS['W11_modfill0_128'] = ("module top(output logic [127:0] o);\n"
    "  logic [127:0] mv;\n  assign mv = '0;\n  assign o = mv;\nendmodule\n")
ARMS['W12_modfillx_128'] = ("module top(output logic [127:0] o);\n"
    "  logic [127:0] mv;\n  assign mv = 'x;\n  assign o = mv;\nendmodule\n")
ARMS['W13_net_fill1_128'] = ("module top(output logic [127:0] o);\n"
    "  wire [127:0] mw;\n  assign mw = '1;\n  assign o = mw;\nendmodule\n")
ARMS['W14_port_fill1_128'] = ("module top(output logic [127:0] o);\n  assign o = '1;\nendmodule\n")

# ---- VIEWS: the same cell inside a CHILD instance (def view vs elab view)
ARMS['V01_child_mod_add'] = ("module sub(output logic [31:0] o);\n  logic [31:0] mv;\n"
    "  assign mv = 32'd2 + 32'd3;\n  assign o = mv;\nendmodule\n"
    "module top(output logic [31:0] o2);\n  sub u0(.o(o2));\nendmodule\n")
ARMS['V02_child_gen_add'] = ("module sub(output logic [31:0] o);\n  if (1) begin : gb\n"
    "    logic [31:0] lv;\n    assign lv = 32'd2 + 32'd3;\n    assign o = lv;\n  end\nendmodule\n"
    "module top(output logic [31:0] o2);\n  sub u0(.o(o2));\nendmodule\n")
ARMS['V03_two_insts'] = ("module sub #(parameter int W = 8)(output logic [31:0] o);\n"
    "  logic [31:0] mv;\n  assign mv = 32'd2 + 32'd3;\n  assign o = mv;\nendmodule\n"
    "module top(output logic [31:0] o2, output logic [31:0] o3);\n"
    "  sub #(8) u0(.o(o2));\n  sub #(16) u1(.o(o3));\nendmodule\n")
# ---- more operator arms not yet covered
OPS = {
  'X01_xnor'   : "32'd6 ~^ 32'd3",
  'X02_eq'     : "32'd2 == 32'd3",
  'X03_neq'    : "32'd2 != 32'd3",
  'X04_ge'     : "32'd2 >= 32'd3",
  'X05_logor'  : "32'd2 || 32'd0",
  'X06_redand' : "&32'd7",
  'X07_redor'  : "|32'd0",
  'X08_redxor' : "^32'd7",
  'X09_pow'    : "32'd2 ** 32'd3",
  'X10_arith_rsh': "32'sd8 >>> 32'd1",
  'X11_unary_plus': "+32'd5",
  'X12_unary_minus_unsized': "-5",
  'X13_hex_sub'  : "32'h7 - 32'h3",
  'X14_hex_mul'  : "32'h2 * 32'h3",
  'X15_bin_sub'  : "32'b111 - 32'b11",
  'X16_dec_and'  : "32'd6 & 32'd3",
  'X17_add_hexdec': "32'h2 + 32'd3",
  'X18_sub_then_add': "(32'd7 - 32'd3) + 32'd1",
  'X19_add_then_sub': "(32'd7 + 32'd3) - 32'd1",
  'X20_mul_then_add': "(32'd7 * 32'd3) + 32'd1",
  'X21_oct_add'  : "32'o7 + 32'o3",
  'X22_unsized_hex': "'h5 + 32'd1",
  'X23_str'      : '"AB"',
  'X24_add_neg_lit': "32'd2 + (-32'd3)",
}
for k, r in OPS.items():
    ARMS[k + '_M'] = ("module top(input logic [31:0] a, output logic [31:0] o2);\n"
        "  logic [31:0] mv;\n  assign mv = %s;\n  assign o2 = mv;\nendmodule\n" % r)
    ARMS[k + '_U'] = ("module top(input logic [31:0] a, output logic [31:0] o2);\n"
        "  if (1) begin : gb\n    logic [31:0] lv;\n    assign lv = %s;\n"
        "    assign o2 = lv;\n  end\nendmodule\n" % r)

def main():
    os.makedirs(GRID, exist_ok=True)
    for k, v in sorted(ARMS.items()):
        d = os.path.join(GRID, k)
        os.makedirs(d, exist_ok=True)
        open(os.path.join(d, 'dut.sv'), 'w').write(v)
    print("ARMS2=%d" % len(ARMS))
main()
