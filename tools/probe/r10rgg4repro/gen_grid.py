#!/usr/bin/env python3
"""r10rgg4/gen_grid.py — writes every grid cell as <cell>/dut.sv.

Each cell is a self-contained single-file design: an interface with a modport,
a leaf module taking an INTERFACE ARRAY port sized by a parameter, one or more
wrapper levels that override that parameter in a named way, and a `top`.

The measured object is the ELAB interface_array's dimension range:
    range[0 : <OPERAND> - 1]
and specifically <OPERAND>'s {vpiSize, value, vpiConstType, Typespec present?}.
"""
import os

IFACE = """\
interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
"""

def leaf(name, pdecl, dim, extra=""):
    return f"""\
module {name} #(
  {pdecl}
)(
  input logic clk,
  ifc4.host  arr[{dim}]
);
{extra}endmodule
"""

CELLS = {}

def cell(nm, body):
    CELLS[nm] = IFACE + body

# ---------------------------------------------------------------- A: override kind
# leaf param `int R`, dim [R].  Vary how R reaches the leaf.
LEAF_INT = leaf("leaf_a", "parameter int R = 4", "R")

# a1 not overridden at all
cell("a1_noovr", LEAF_INT + """\
module top;
  logic clk;
  ifc4 arr[4]();
  leaf_a u (clk, arr);
endmodule
""")
# a2 overridden by an UNSIZED decimal literal
cell("a2_ovr_lit", LEAF_INT + """\
module top;
  logic clk;
  ifc4 arr[6]();
  leaf_a #(.R(6)) u (clk, arr);
endmodule
""")
# a3 overridden by a SIZED literal
cell("a3_ovr_sizedlit", LEAF_INT + """\
module top;
  logic clk;
  ifc4 arr[6]();
  leaf_a #(.R(8'd6)) u (clk, arr);
endmodule
""")
# a4 overridden by a PARAMETER REFERENCE (the HEAD shape)
cell("a4_ovr_paramref", LEAF_INT + """\
module mid_a4 #(parameter int R = 4)(input logic clk, ifc4.host arr[R]);
  leaf_a #(.R(R)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_a4 #(.R(6)) m (clk, arr);
endmodule
""")
# a5 overridden by an ARITHMETIC expression over a param ref
cell("a5_ovr_paramarith", LEAF_INT + """\
module mid_a5 #(parameter int R = 4)(input logic clk, ifc4.host arr[R-1]);
  leaf_a #(.R(R-1)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_a5 #(.R(7)) m (clk, arr);
endmodule
""")
# a6 overridden by a param ref whose PARENT param is itself NOT overridden
cell("a6_ovr_ref_to_default", LEAF_INT + """\
module mid_a6 #(parameter int R = 4)(input logic clk, ifc4.host arr[R]);
  leaf_a #(.R(R)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[4]();
  mid_a6 m (clk, arr);
endmodule
""")
# a6b overridden by a reference to a TOP-LEVEL localparam
cell("a6b_ovr_toplocalparam", LEAF_INT + """\
module top;
  logic clk;
  localparam int TLP = 6;
  ifc4 arr[6]();
  leaf_a #(.R(TLP)) u (clk, arr);
endmodule
""")
# a6c overridden by a reference to a PACKAGE parameter
cell("a6c_ovr_pkgparam", """\
package pk4;
  parameter int PR = 6;
endpackage
""" + LEAF_INT + """\
module top;
  logic clk;
  ifc4 arr[6]();
  leaf_a #(.R(pk4::PR)) u (clk, arr);
endmodule
""")
# a7 overridden POSITIONALLY by a param ref
cell("a7_ovr_pos_paramref", LEAF_INT + """\
module mid_a7 #(parameter int R = 4)(input logic clk, ifc4.host arr[R]);
  leaf_a #(R) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_a7 #(6) m (clk, arr);
endmodule
""")
# a8 TWO wrapper levels, param ref at each (rggen's real depth)
cell("a8_two_level_paramref", LEAF_INT + """\
module mid_a8 #(parameter int R = 4)(input logic clk, ifc4.host arr[R]);
  leaf_a #(.R(R)) u (clk, arr);
endmodule
module out_a8 #(parameter int R = 4)(input logic clk, ifc4.host arr[R]);
  mid_a8 #(.R(R)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  out_a8 #(.R(6)) m (clk, arr);
endmodule
""")

# ---------------------------------------------------------------- B: leaf param TYPE
for tag, pd in [("b1_int", "parameter int R = 4"),
                ("b2_untyped", "parameter R = 4"),
                ("b3_bit8", "parameter bit [7:0] R = 4"),
                ("b4_logic8", "parameter logic [7:0] R = 4"),
                ("b5_integer", "parameter integer R = 4"),
                ("b6_longint", "parameter longint R = 4"),
                ("b7_shortint", "parameter shortint R = 4"),
                ("b8_byte", "parameter byte R = 4"),
                ("b9_intu", "parameter int unsigned R = 4")]:
    # NOT overridden
    cell(tag + "_noovr", leaf("leaf_" + tag, pd, "R") + f"""\
module top;
  logic clk;
  ifc4 arr[4]();
  leaf_{tag} u (clk, arr);
endmodule
""")
    # overridden by a PARAM REF
    cell(tag + "_paramref", leaf("leaf_" + tag, pd, "R") + f"""\
module mid_{tag} #(parameter int R = 4)(input logic clk, ifc4.host arr[R]);
  leaf_{tag} #(.R(R)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_{tag} #(.R(6)) m (clk, arr);
endmodule
""")

# ---------------------------------------------------------------- C: dim EXPRESSION
# `f4` = the dim's value with R=4 (the default), `f6` = with R=6 (overridden).
for tag, dim, f4, f6 in [("c1_p", "R", 4, 6), ("c2_pm1", "R-1", 3, 5),
                         ("c3_p2", "R*2", 8, 12), ("c4_clog2", "$clog2(R)", 2, 3),
                         ("c5_ppq", "R+Q", 6, 8), ("c6_paren", "(R)", 4, 6),
                         ("c7_msblsb", "R-1:0", 4, 6), ("c8_lit", "6", 6, 6),
                         ("c9_litarith", "3*2", 6, 6)]:
    pd = "parameter int R = 4, parameter int Q = 2"
    cell(tag + "_paramref", leaf("leaf_" + tag, pd, dim) + f"""\
module mid_{tag} #(parameter int R = 4, parameter int Q = 2)(input logic clk, ifc4.host arr[{dim}]);
  leaf_{tag} #(.R(R), .Q(Q)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[{f6}]();
  mid_{tag} #(.R(6)) m (clk, arr);
endmodule
""")
    cell(tag + "_noovr", leaf("leaf_" + tag, pd, dim) + f"""\
module top;
  logic clk;
  ifc4 arr[{f4}]();
  leaf_{tag} u (clk, arr);
endmodule
""")

# ------------------------------------------------- G: the OVERRIDE CHAIN's terminal
# leaf `parameter int R`, dim [R], overridden by a reference to a parent parameter
# whose own TYPE varies and which is NOT itself overridden.
for tag, pd in [("g1_int", "parameter int P = 6"),
                ("g2_untyped", "parameter P = 6"),
                ("g3_bit8", "parameter bit [7:0] P = 6"),
                ("g4_longint", "parameter longint P = 6"),
                ("g5_byte", "parameter byte P = 6"),
                ("g6_intu", "parameter int unsigned P = 6"),
                ("g7_integer", "parameter integer P = 6"),
                ("g8_untyped_sized", "parameter P = 8'd6"),
                ("g9_untyped_arith", "parameter P = 3*2")]:
    cell(tag, LEAF_INT + f"""\
module mid_{tag} #({pd})(input logic clk, ifc4.host arr[6]);
  leaf_a #(.R(P)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_{tag} m (clk, arr);
endmodule
""")

# ------------------------------------------------- H: the OVERRIDE EXPRESSION's kind
for tag, ovr in [("h1_unsized_dec", "6"),
                 ("h2_sized_dec", "8'd6"),
                 ("h3_sized_hex", "32'h6"),
                 ("h4_unsized_based", "'d6"),
                 ("h5_arith_lit", "3*2"),
                 ("h6_paren_lit", "(6)"),
                 ("h7_clog2_lit", "$clog2(64)"),
                 ("h8_cast", "int'(6)"),
                 ("h9_concat", "{3'b011,1'b0}"),
                 ("ha_ternary", "(1) ? 6 : 0"),
                 ("hb_unary_minus", "-(-6)"),
                 ("hc_shift", "3<<1"),
                 ("hd_cmp_sum", "(3>1)+5"),
                 ("he_realcast", "int'(6.0)"),
                 ("hf_localparam_arith", "6-0")]:
    cell(tag, LEAF_INT + f"""\
module top;
  logic clk;
  ifc4 arr[6]();
  leaf_a #(.R({ovr})) u (clk, arr);
endmodule
""")

# ---------------------------------------------------------------- D: OTHER range sites
# The same [R] dim on things that are NOT interface-array ports, to bound the law.
cell("d1_logic_member", """\
module leaf_d1 #(parameter int R = 4)(input logic clk);
  logic [R-1:0] v;
  logic         w [R];
  assign v = '0;
endmodule
module mid_d1 #(parameter int R = 4)(input logic clk);
  leaf_d1 #(.R(R)) u (clk);
endmodule
module top;
  logic clk;
  mid_d1 #(.R(6)) m (clk);
endmodule
""")
cell("d2_module_array_port", """\
module leaf_d2 #(parameter int R = 4)(input logic [R-1:0] p, output logic [R-1:0] q);
  assign q = p;
endmodule
module mid_d2 #(parameter int R = 4)(input logic [R-1:0] p, output logic [R-1:0] q);
  leaf_d2 #(.R(R)) u (p, q);
endmodule
module top;
  logic [5:0] p, q;
  mid_d2 #(.R(6)) m (p, q);
endmodule
""")
cell("d3_iface_nonarray_port", IFACE and """\
module leaf_d3 #(parameter int R = 4)(input logic clk, ifc4.host s);
  logic [R-1:0] v;
endmodule
module mid_d3 #(parameter int R = 4)(input logic clk, ifc4.host s);
  leaf_d3 #(.R(R)) u (clk, s);
endmodule
module top;
  logic clk;
  ifc4 s();
  mid_d3 #(.R(6)) m (clk, s);
endmodule
""")
cell("d4_iface_array_inst", """\
module leaf_d4 #(parameter int R = 4)(input logic clk);
  ifc4 arr[R]();
endmodule
module mid_d4 #(parameter int R = 4)(input logic clk);
  leaf_d4 #(.R(R)) u (clk);
endmodule
module top;
  logic clk;
  mid_d4 #(.R(6)) m (clk);
endmodule
""")
cell("d5_module_array_inst", """\
module tiny_d5(input logic clk); endmodule
module leaf_d5 #(parameter int R = 4)(input logic clk);
  tiny_d5 u[R] (clk);
endmodule
module mid_d5 #(parameter int R = 4)(input logic clk);
  leaf_d5 #(.R(R)) u (clk);
endmodule
module top;
  logic clk;
  mid_d5 #(.R(6)) m (clk);
endmodule
""")
cell("d6_typedef_range", """\
module leaf_d6 #(parameter int R = 4)(input logic clk);
  typedef logic [R-1:0] w_t;
  w_t v;
endmodule
module mid_d6 #(parameter int R = 4)(input logic clk);
  leaf_d6 #(.R(R)) u (clk);
endmodule
module top;
  logic clk;
  mid_d6 #(.R(6)) m (clk);
endmodule
""")
cell("d7_param_range", """\
module leaf_d7 #(parameter int R = 4)(input logic clk);
  localparam logic [R-1:0] M = '1;
endmodule
module mid_d7 #(parameter int R = 4)(input logic clk);
  leaf_d7 #(.R(R)) u (clk);
endmodule
module top;
  logic clk;
  mid_d7 #(.R(6)) m (clk);
endmodule
""")
cell("d8_gen_iface_array", """\
module leaf_d8 #(parameter int R = 4)(input logic clk, ifc4.host arr[R]);
endmodule
module mid_d8 #(parameter int R = 4)(input logic clk, ifc4.host arr[R]);
  generate if (1) begin : g
    leaf_d8 #(.R(R)) u (clk, arr);
  end endgenerate
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_d8 #(.R(6)) m (clk, arr);
endmodule
""")

def main():
    here = os.path.dirname(os.path.abspath(__file__))
    for nm, txt in sorted(CELLS.items()):
        d = os.path.join(here, nm)
        os.makedirs(d, exist_ok=True)
        with open(os.path.join(d, 'dut.sv'), 'w') as f:
            f.write(txt)
    print(f"cells={len(CELLS)}")

if __name__ == '__main__':
    main()
