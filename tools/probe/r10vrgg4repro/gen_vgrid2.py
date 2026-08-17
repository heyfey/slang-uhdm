#!/usr/bin/env python3
"""r10vrgg4/gen_vgrid2.py — the SECOND adversarial wave.

Wave 1 (gen_vgrid.py) found BROKEN=0 but three law-level refutations.  Wave 2
closes the two spaces that could still hide a pristine-right -> patched-wrong
cell:

  v5g..v5k  the PREDEFINED-INTEGER space EXHAUSTIVELY (the patch NARROWED the
            non-overridden typespec gate from `isPredefinedInteger()` to plain
            signed `int`; every type the OLD gate said Y to must be checked)
  v7*       the arithmetic-override SIGNEDNESS law (`R+2` reads UINT in golden,
            INT in ours -- is the distinguisher the operand's KIND?)
  v1d/v1e   the Synth path writes `foldVal` (the element count) where the
            Verbatim path writes the literal's own value; a TRUNCATING leaf
            makes those two disagree.
"""
import os
HERE = os.path.dirname(os.path.abspath(__file__))
IFC = """interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
"""
CELLS = {}
def cell(n, b): CELLS[n] = IFC + b

# ---- v5g..v5k: the predefined-integer space, NON-overridden
for tag, ty in [('v5g_noovr_integer_u', 'integer unsigned R'),
                ('v5h_noovr_longint_u', 'longint unsigned R'),
                ('v5i_noovr_shortint_u','shortint unsigned R'),
                ('v5j_noovr_byte_u',    'byte unsigned R'),
                ('v5k_noovr_int_signed','int signed R'),
                ('v5l_noovr_logic_sgn', 'logic signed [7:0] R'),
                ('v5m_noovr_implicit_sgn','signed [7:0] R'),
                ('v5n_noovr_bit1',      'bit R')]:
    n = 1 if tag.endswith('bit1') else 4
    cell(tag, """module leaf_%s #(
  parameter %s = %d
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
""" % (tag, ty, n, n, tag))

# ---- v7*: arithmetic-override signedness
def arith(tag, pre, midparams, expr, n, midbody_pre=''):
    cell(tag, pre + """module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module mid_%s %s(input logic clk, ifc4.host arr[%d]);
%s  leaf_a #(.R(%s)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[%d]();
  mid_%s %s m (clk, arr);
endmodule
""" % (tag, midparams, n, midbody_pre, expr, n, tag,
       '#(.R(4))' if 'ovrparam' in tag else ''))

arith('v7a_arith_paramref',  '', '#(parameter int P = 4)', 'P+2', 6)
arith('v7b_arith_ovrparam',  '', '#(parameter int R = 2)', 'R+2', 6)
arith('v7c_arith_localparam','', '#(parameter int Z = 0)', 'LP+2', 6,
      '  localparam int LP = 4;\n')
arith('v7d_arith_pure_lit',  '', '#(parameter int Z = 0)', '4+2', 6)
arith('v7e_arith_pkgparam',
      'package pk_v7e;\n  parameter int PR = 4;\nendpackage\n',
      '#(parameter int Z = 0)', 'pk_v7e::PR+2', 6)
arith('v7f_arith_unsigned_p','', '#(parameter int unsigned P = 4)', 'P+2', 6)
arith('v7g_mul_paramref',    '', '#(parameter int P = 3)', 'P*2', 6)
arith('v7h_unary_paramref',  '', '#(parameter int P = 6)', '-(-P)', 6)
arith('v7i_shift_paramref',  '', '#(parameter int P = 3)', 'P<<1', 6)
arith('v7j_clog2_paramref',  '', '#(parameter int P = 64)', '$clog2(P)', 6)
arith('v7k_ternary_paramref','', '#(parameter int P = 6)', '(1)?P:0', 6)
arith('v7l_cast_paramref',   '', '#(parameter int P = 6)', "int'(P)", 6)

# ---- v1d/v1e: the Synth path's value vs the real element count
cell('v1d_trunc_synth', """module leaf_v1d #(
  parameter bit [1:0] R = 2
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module mid_v1d #(parameter bit [2:0] P = 6)(input logic clk, ifc4.host arr[2]);
  leaf_v1d #(.R(P)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[2]();
  mid_v1d m (clk, arr);
endmodule
""")
cell('v1e_trunc_verbatim', """module leaf_v1d #(
  parameter bit [1:0] R = 2
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 arr[2]();
  leaf_v1d #(.R(6)) u (clk, arr);
endmodule
""")
cell('v1f_trunc_arith', """module leaf_v1d #(
  parameter bit [1:0] R = 2
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 arr[2]();
  leaf_v1d #(.R(3*2)) u (clk, arr);
endmodule
""")
# legal replication / concat overrides (wave 1's were arithmetically wrong)
cell('v6i_ovr_replication', """module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  leaf_a #(.R({1{3'b110}})) u (clk, arr);
endmodule
""")
cell('v6j_ovr_signed_based', """module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  leaf_a #(.R(8'sd6)) u (clk, arr);
endmodule
""")
cell('v6k_ovr_octbin', """module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  leaf_a #(.R(3'b110)) u (clk, arr);
endmodule
""")
for n, txt in CELLS.items():
    d = os.path.join(HERE, n); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(txt)
print('CELLS=%d' % len(CELLS))
