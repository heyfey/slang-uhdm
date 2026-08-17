#!/usr/bin/env python3
"""r10vrgg4/gen_vgrid.py — ADVERSARIAL cells for r10rgg4's § sizeDimOvrChain4.

Each cell is a self-contained dut.sv whose `top` instantiates a chain that ends
in an ELABORATED interface-array port with a SIZE-form dimension.  The cells are
chosen to attack the law's stated boundaries, not to confirm them:

  v1*  truncating / widening overrides  (the Verbatim path copies the literal
       object -- does its VALUE still equal the real element count?)
  v2*  defparam and other non-#() override routes
  v3*  signed / 4-state / typedef'd / enum / real terminals
  v4*  deeper chains (3 and 4 hops), cross-hierarchy and interface-param hops
  v5*  the NON-overridden typespec gate (the pass NARROWED it: only plain `int`)
  v6*  shapes that fall off the modelled end (fallback path, which the patch
       now strips the typespec from)
"""
import os, sys

HERE = os.path.dirname(os.path.abspath(__file__))

IFC = """interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
"""

CELLS = {}

def cell(name, body):
    CELLS[name] = IFC + body

# ---------------------------------------------------------------- v1 truncation
# `bit [2:0] R` overridden with 12 -> R == 4.  The Verbatim path emits the
# literal `12` VERBATIM; the array really has 4 elements.
cell('v1a_trunc_bit3_lit', """module leaf_v1a #(
  parameter bit [2:0] R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 arr[4]();
  leaf_v1a #(.R(12)) u (clk, arr);
endmodule
""")
# same, but the override is a PARAMREF whose terminal is a wide literal
cell('v1b_trunc_bit3_ref', """module leaf_v1a #(
  parameter bit [2:0] R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module mid_v1b #(parameter int R = 4)(input logic clk, ifc4.host arr[4]);
  leaf_v1a #(.R(R)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[4]();
  mid_v1b #(.R(12)) m (clk, arr);
endmodule
""")
# narrow terminal widened by the leaf: terminal `bit [2:0] P = 6`, leaf `int R`
cell('v1c_narrow_terminal', """module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module mid_v1c #(parameter bit [2:0] P = 6)(input logic clk, ifc4.host arr[6]);
  leaf_a #(.R(P)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_v1c m (clk, arr);
endmodule
""")

# ------------------------------------------------------------------ v2 defparam
cell('v2a_defparam', """module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  leaf_a u (clk, arr);
  defparam u.R = 6;
endmodule
""")
# an override that equals the DEFAULT value (isOverridden() is still true)
cell('v2b_ovr_same_as_default', """module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 arr[4]();
  leaf_a #(.R(4)) u (clk, arr);
endmodule
""")
# EMPTY parameter list `#()`
cell('v2c_empty_hash', """module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 arr[4]();
  leaf_a #() u (clk, arr);
endmodule
""")

# ------------------------------------------------------- v3 terminal type zoo
for tag, ty, dflt, n in [
    ('v3a_signed_vec',   'bit signed [7:0] P',  '6', 6),
    ('v3b_logic_signed', 'logic signed [7:0] P','6', 6),
    ('v3c_reg8',         'reg [7:0] P',         '6', 6),
    ('v3d_packed2d',     'bit [1:0][3:0] P',    '6', 6),
    ('v3e_int_via_td',   'myint_v P',           '6', 6),
    ('v3f_real',         'real P',              '6.0', 6),
    ('v3g_time',         'time P',              '6', 6),
]:
    pre = 'typedef int myint_v;\n' if 'td' in tag else ''
    cell(tag, pre + """module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module mid_%s #(parameter %s = %s)(input logic clk, ifc4.host arr[%d]);
  leaf_a #(.R(P)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[%d]();
  mid_%s m (clk, arr);
endmodule
""" % (tag, ty, dflt, n, n, tag))

# enum-member terminal: the override names an ENUM VALUE (not a Parameter) ->
# sizeDimOvrEnc4 returns None and the FALLBACK path runs.
cell('v3h_enum_member', """package pk_v3h;
  typedef enum int { E_A = 3, E_B = 6 } e_v;
endpackage
module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  leaf_a #(.R(pk_v3h::E_B)) u (clk, arr);
endmodule
""")
# enum-TYPED terminal parameter
cell('v3i_enum_param', """package pk_v3i;
  typedef enum int { E_A = 3, E_B = 6 } e_v;
endpackage
module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module mid_v3i #(parameter pk_v3i::e_v P = pk_v3i::E_B)
               (input logic clk, ifc4.host arr[6]);
  leaf_a #(.R(P)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_v3i m (clk, arr);
endmodule
""")

# ------------------------------------------------------------- v4 deeper chains
cell('v4a_three_hop', """module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module lvl1_v4a #(parameter int R = 4)(input logic clk, ifc4.host arr[R]);
  leaf_a #(.R(R)) u (clk, arr);
endmodule
module lvl2_v4a #(parameter int R = 4)(input logic clk, ifc4.host arr[R]);
  lvl1_v4a #(.R(R)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  lvl2_v4a #(.R(6)) m (clk, arr);
endmodule
""")
cell('v4b_four_hop_arith_mid', """module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module lvl1_v4b #(parameter int R = 4)(input logic clk, ifc4.host arr[R]);
  leaf_a #(.R(R)) u (clk, arr);
endmodule
module lvl2_v4b #(parameter int R = 4)(input logic clk, ifc4.host arr[R+2]);
  lvl1_v4b #(.R(R+2)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  lvl2_v4b #(.R(4)) m (clk, arr);
endmodule
""")
# a chain hop whose terminal is a NON-overridden param of the GRANDparent,
# reached hierarchically
cell('v4c_hier_ref', """module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  localparam int TLP = 6;
  ifc4 arr[6]();
  leaf_a #(.R(top.TLP)) u (clk, arr);
endmodule
""")
# override sourced from an INTERFACE instance's parameter
cell('v4d_iface_param_src', """module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 #(.W(6)) arr[6]();
  leaf_a #(.R(arr[0].W)) u (clk, arr);
endmodule
""")
# chain where the middle hop is a LOCALPARAM computed from an overridden param
cell('v4e_localparam_hop', """module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module mid_v4e #(parameter int R = 4)(input logic clk, ifc4.host arr[6]);
  localparam int LR = R;
  leaf_a #(.R(LR)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_v4e #(.R(6)) m (clk, arr);
endmodule
""")
# generate-nested chain
cell('v4f_gen_chain', """module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module mid_v4f #(parameter int R = 4)(input logic clk, ifc4.host arr[R]);
  if (1) begin : g
    leaf_a #(.R(R)) u (clk, arr);
  end
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_v4f #(.R(6)) m (clk, arr);
endmodule
""")

# ------------------------------------ v5 the NON-OVERRIDDEN typespec gate
for tag, ty, n in [
    ('v5a_noovr_int_td',      'myint_v R',            4),
    ('v5b_noovr_signed_vec',  'bit signed [7:0] R',   4),
    ('v5c_noovr_time',        'time R',               4),
    ('v5d_noovr_enumparam',   'pk_v5::e_v R',         3),
    ('v5e_noovr_reg8',        'reg [7:0] R',          4),
    ('v5f_noovr_packed2d',    'bit [1:0][3:0] R',     4),
]:
    pre = ''
    dflt = '4'
    if 'td' in tag:
        pre = 'typedef int myint_v;\n'
    if 'enumparam' in tag:
        pre = ('package pk_v5;\n  typedef enum int { E_A = 3, E_B = 6 } e_v;\n'
               'endpackage\n')
        dflt = 'pk_v5::E_A'
    cell(tag, pre + """module leaf_%s #(
  parameter %s = %s
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 arr[%d]();
  leaf_%s u (clk, arr);
endmodule
""" % (tag, ty, dflt, n, tag))

# ------------------------------------------------- v6 unmodelled override shapes
cell('v6a_ovr_string_index', """package pk_v6a;
  parameter int TAB [0:3] = '{1,2,6,4};
endpackage
module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  leaf_a #(.R(pk_v6a::TAB[2])) u (clk, arr);
endmodule
""")
cell('v6b_ovr_struct_member', """package pk_v6b;
  typedef struct packed { int a; int b; } s_v;
  parameter s_v S = '{a:3, b:6};
endpackage
module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  leaf_a #(.R(pk_v6b::S.b)) u (clk, arr);
endmodule
""")
cell('v6c_ovr_partsel', """module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module mid_v6c #(parameter bit [15:0] P = 16'h0006)
               (input logic clk, ifc4.host arr[6]);
  leaf_a #(.R(P[7:0])) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_v6c m (clk, arr);
endmodule
""")
cell('v6d_ovr_bitsof', """module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  leaf_a #(.R($bits(logic [5:0]))) u (clk, arr);
endmodule
""")
cell('v6e_ovr_signed_cast', """module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  leaf_a #(.R(signed'(6))) u (clk, arr);
endmodule
""")
cell('v6f_ovr_sizecast', """module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  leaf_a #(.R(8'(6))) u (clk, arr);
endmodule
""")
cell('v6g_ovr_replication', """module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  leaf_a #(.R({2{3'b011}})) u (clk, arr);
endmodule
""")
cell('v6h_ovr_unbased', """module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 arr[1]();
  leaf_a #(.R('1)) u (clk, arr);
endmodule
""")

for n, txt in CELLS.items():
    d = os.path.join(HERE, n)
    os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, 'dut.sv'), 'w') as f:
        f.write(txt)
print('\n'.join(sorted(CELLS)))
print('CELLS=%d' % len(CELLS))
