#!/usr/bin/env python3
"""vrgg13 adversarial arm generator — one directory per cell, top.sv inside."""
import os, sys
OUT = sys.argv[1] if len(sys.argv) > 1 else '/tmp/vrgg13_arms'
cells = {}

# ---------------------------------------------------------------- A: argument shapes
ARGS = {
  'bare'     : 'P',
  'lparam'   : 'Q',
  'expr'     : 'P+1',
  'sel'      : 'ARRP[1]',
  'nest'     : 'fn2(P)',
  'lit'      : '3',
  'cast'     : "int'(P)",
  'concat'   : '{P[3:0],P[3:0]}',
  'tern'     : 'P>1?P:Q',
  'repl'     : '{2{P[1:0]}}',
  'neg'      : '-P',
  'sysfn'    : '$clog2(P)',
}
FORMALS = {
  'int'    : 'int n',
  'integer': 'integer n',
  'byte'   : 'byte n',
  'shortint':'shortint n',
  'longint': 'longint n',
  'bitN'   : 'bit [7:0] n',
  'logicN' : 'logic [31:0] n',
  'bitsgn' : 'bit signed [31:0] n',
  'bare'   : 'n',
  'sgnbare': 'signed n',
  'tdint'  : 'ti_t n',
  'tdvec'  : 'tv_t n',
}
def mid_body(argexpr, formal, extra=''):
    tds = ''
    if 'ti_t' in formal: tds += "typedef int ti_t;\n"
    if 'tv_t' in formal: tds += "typedef bit [7:0] tv_t;\n"
    pre = ''
    if 'ARRP' in argexpr: pre += "  localparam bit [3:0] ARRP [0:3] = '{1,2,3,4};\n"
    if 'fn2' in argexpr: pre += "  function automatic int fn2(int n); return n; endfunction\n"
    return f"""
{tds}module mid #(
  parameter int P = 8'h07
)(
  output logic o
);
  localparam int Q = 4'b0110;
{pre}  function automatic bit [P-1:0][15:0] flp({formal});
    bit [P-1:0][15:0] list;
    list = '0;
    list[0] = 16'(n);
    return list;
  endfunction
{extra}
  localparam bit [P-1:0][15:0] LP = flp({argexpr});
  assign o = LP[0][0];
endmodule

module top;
  logic o1,o2,o3,o4,o5,o6;
  mid #(.P(2))        u1 (.o(o1));
  mid #(.P(8'h03))    u2 (.o(o2));
  mid #(.P(4'b0101))  u3 (.o(o3));
  mid #(.P(3'o5))     u4 (.o(o4));
  mid #(.P(1+3))      u5 (.o(o5));
  mid                 u6 (.o(o6));
endmodule
"""
for an, ax in ARGS.items():
    for fn, fx in FORMALS.items():
        cells[f'a_{an}__{fn}'] = mid_body(ax, fx)

# ---------------------------------------------------------------- B: param kinds / homes
cells['b_portparam'] = mid_body('P', 'int n')
cells['b_localparam'] = mid_body('Q', 'int n')
cells['b_pkgparam'] = """
package pk;
  parameter int PP = 8'h05;
  function automatic int pfn(int n); return n; endfunction
endpackage
module mid #(parameter int P = 4)(output logic o);
  import pk::*;
  function automatic bit [P-1:0][15:0] flp(int n);
    bit [P-1:0][15:0] list; list = '0; list[0]=16'(n); return list;
  endfunction
  localparam bit [P-1:0][15:0] LP = flp(pk::PP);
  assign o = LP[0][0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""
cells['b_unitparam'] = """
parameter int UP = 8'h06;
function automatic int ufn(int n); return n; endfunction
module mid #(parameter int P = 4)(output logic o);
  function automatic bit [P-1:0][15:0] flp(int n);
    bit [P-1:0][15:0] list; list='0; list[0]=16'(n); return list;
  endfunction
  localparam bit [P-1:0][15:0] LP = flp(UP);
  assign o = LP[0][0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""
cells['b_genscope'] = """
module mid #(parameter int P = 8'h07)(output logic o);
  function automatic bit [P-1:0][15:0] flp(int n);
    bit [P-1:0][15:0] list; list='0; list[0]=16'(n); return list;
  endfunction
  for (genvar gi=0; gi<2; gi++) begin : g
    localparam int GP = gi+1;
    localparam bit [P-1:0][15:0] LG = flp(GP);
  end
  assign o = g[0].LG[0][0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""
cells['b_genscope_outerparam'] = """
module mid #(parameter int P = 8'h07)(output logic o);
  function automatic bit [P-1:0][15:0] flp(int n);
    bit [P-1:0][15:0] list; list='0; list[0]=16'(n); return list;
  endfunction
  if (1) begin : g
    localparam bit [P-1:0][15:0] LG = flp(P);
  end
  assign o = g.LG[0][0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""
cells['b_pkghome'] = """
package pk;
  parameter int PP = 8'h05;
  function automatic bit [PP-1:0][15:0] flp(int n);
    bit [PP-1:0][15:0] list; list='0; list[0]=16'(n); return list;
  endfunction
  localparam bit [PP-1:0][15:0] LPK = flp(PP);
endpackage
module top; logic o; assign o = pk::LPK[0][0]; endmodule
"""
cells['b_class'] = """
class C #(parameter int P = 8'h03);
  static function int cf(int n); return n; endfunction
  localparam int CL = cf(P);
endclass
module mid #(parameter int P = 8'h07)(output logic o);
  function automatic bit [P-1:0][15:0] flp(int n);
    bit [P-1:0][15:0] list; list='0; list[0]=16'(n); return list;
  endfunction
  localparam bit [P-1:0][15:0] LP = flp(C#(4)::CL);
  assign o = LP[0][0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""
cells['b_ifacehome'] = """
interface ifc #(parameter int P = 8'h07)();
  function automatic bit [P-1:0][15:0] flp(int n);
    bit [P-1:0][15:0] list; list='0; list[0]=16'(n); return list;
  endfunction
  localparam bit [P-1:0][15:0] LI = flp(P);
endinterface
module top; ifc #(.P(2)) u1(); ifc #(.P(8'h03)) u2(); endmodule
"""

# ---------------------------------------------------------------- C: callee kinds
cells['c_pkgfn'] = """
package pk;
  function automatic bit [3:0][15:0] pflp(int n);
    bit [3:0][15:0] list; list='0; list[0]=16'(n); return list;
  endfunction
endpackage
module mid #(parameter int P = 8'h07)(output logic o);
  localparam bit [3:0][15:0] LP = pk::pflp(P);
  assign o = LP[0][0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""
cells['c_unitfn'] = """
function automatic bit [3:0][15:0] uflp(int n);
  bit [3:0][15:0] list; list='0; list[0]=16'(n); return list;
endfunction
module mid #(parameter int P = 8'h07)(output logic o);
  localparam bit [3:0][15:0] LP = uflp(P);
  assign o = LP[0][0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""
cells['c_classstatic'] = """
class K;
  static function bit [3:0][15:0] kflp(int n);
    bit [3:0][15:0] list; list='0; list[0]=16'(n); return list;
  endfunction
endclass
module mid #(parameter int P = 8'h07)(output logic o);
  localparam bit [3:0][15:0] LP = K::kflp(P);
  assign o = LP[0][0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""
cells['c_named_inorder'] = """
module mid #(parameter int P = 8'h07)(output logic o);
  function automatic bit [P-1:0][15:0] flp(int a, int b);
    bit [P-1:0][15:0] list; list='0; list[0]=16'(a+b); return list;
  endfunction
  localparam int Q = 4'b0110;
  localparam bit [P-1:0][15:0] LP = flp(.a(P), .b(Q));
  assign o = LP[0][0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""
cells['c_named_reordered'] = """
module mid #(parameter int P = 8'h07)(output logic o);
  function automatic bit [P-1:0][15:0] flp(int a, bit [7:0] b);
    bit [P-1:0][15:0] list; list='0; list[0]=16'(a+b); return list;
  endfunction
  localparam int Q = 4'b0110;
  localparam bit [P-1:0][15:0] LP = flp(.b(Q), .a(P));
  assign o = LP[0][0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""
cells['c_default_arg'] = """
module mid #(parameter int P = 8'h07)(output logic o);
  function automatic bit [P-1:0][15:0] flp(int a, int b = 9);
    bit [P-1:0][15:0] list; list='0; list[0]=16'(a+b); return list;
  endfunction
  localparam bit [P-1:0][15:0] LP = flp(P);
  assign o = LP[0][0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""
cells['c_twoargs'] = """
module mid #(parameter int P = 8'h07)(output logic o);
  localparam int Q = 4'b0110;
  function automatic bit [P-1:0][15:0] flp(int a, int b);
    bit [P-1:0][15:0] list; list='0; list[0]=16'(a+b); return list;
  endfunction
  localparam bit [P-1:0][15:0] LP = flp(P, Q);
  assign o = LP[0][0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""

# ---------------------------------------------------------------- D: the elabCallFormal collision
cells['d_barefirst_collision'] = """
module mid #(parameter int P = 8'h07)(output logic o);
  function automatic int gbare(n); return n; endfunction
  function automatic bit [P-1:0][15:0] flp(int n);
    bit [P-1:0][15:0] list; list='0; list[0]=16'(n); return list;
  endfunction
  localparam int GG = gbare(P);
  localparam bit [P-1:0][15:0] LP = flp(P);
  assign o = LP[0][0] ^ GG[0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""
cells['d_barelast_collision'] = """
module mid #(parameter int P = 8'h07)(output logic o);
  function automatic int gbare(n); return n; endfunction
  function automatic bit [P-1:0][15:0] flp(int n);
    bit [P-1:0][15:0] list; list='0; list[0]=16'(n); return list;
  endfunction
  localparam bit [P-1:0][15:0] LP = flp(P);
  localparam int GG = gbare(P);
  assign o = LP[0][0] ^ GG[0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""
cells['d_rangedformal_collision'] = """
module mid #(parameter int P = 8'h07)(output logic o);
  function automatic int gr(input [7:0] n); return n; endfunction
  function automatic bit [P-1:0][15:0] flp(int n);
    bit [P-1:0][15:0] list; list='0; list[0]=16'(n); return list;
  endfunction
  localparam int GG = gr(P);
  localparam bit [P-1:0][15:0] LP = flp(P);
  assign o = LP[0][0] ^ GG[0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""

# ---------------------------------------------------------------- E: dimension axis
cells['e_1d'] = """
module mid #(parameter int P = 8'h07)(output logic o);
  function automatic bit [15:0] flp(int n); return 16'(n); endfunction
  localparam bit [15:0] LP = flp(P);
  assign o = LP[0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""
cells['e_3d'] = """
module mid #(parameter int P = 8'h07)(output logic o);
  function automatic bit [1:0][P-1:0][15:0] flp(int n);
    bit [1:0][P-1:0][15:0] list; list='0; list[0][0]=16'(n); return list;
  endfunction
  localparam bit [1:0][P-1:0][15:0] LP = flp(P);
  assign o = LP[0][0][0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""
cells['e_typedef2d'] = """
typedef bit [3:0][15:0] t2d_t;
module mid #(parameter int P = 8'h07)(output logic o);
  function automatic t2d_t flp(int n);
    t2d_t list; list='0; list[0]=16'(n); return list;
  endfunction
  localparam t2d_t LP = flp(P);
  assign o = LP[0][0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""
cells['e_typedefvec_extradim'] = """
typedef bit [15:0] w_t;
module mid #(parameter int P = 8'h07)(output logic o);
  function automatic w_t [3:0] flp(int n);
    w_t [3:0] list; list='0; list[0]=16'(n); return list;
  endfunction
  localparam w_t [3:0] LP = flp(P);
  assign o = LP[0][0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""
cells['e_unpacked'] = """
module mid #(parameter int P = 8'h07)(output logic o);
  function automatic int flp(int n); return n; endfunction
  localparam int LP [0:3] = '{flp(P), 1, 2, 3};
  assign o = LP[0][0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""

# ---------------------------------------------------------------- F: positions
cells['f_contassign'] = """
module mid #(parameter int P = 8'h07)(output logic [15:0] o);
  function automatic bit [P-1:0][15:0] flp(int n);
    bit [P-1:0][15:0] list; list='0; list[0]=16'(n); return list;
  endfunction
  assign o = flp(P)[0];
endmodule
module top; logic [15:0] o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""
cells['f_portactual'] = """
module leaf #(parameter int W = 1)(output logic o); assign o = 1'b0; endmodule
module mid #(parameter int P = 8'h07)(output logic o);
  function automatic int flp(int n); return n; endfunction
  localparam bit [P-1:0][15:0] LP2 = '0;
  leaf #(.W(flp(P))) u (.o(o));
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""
cells['f_rangebound'] = """
module mid #(parameter int P = 8'h07)(output logic o);
  function automatic int flp(int n); return n+1; endfunction
  localparam bit [P-1:0][15:0] LPM = '0;
  logic [flp(P):0] v;
  assign o = v[0] ^ LPM[0][0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""

# ---------------------------------------------------------------- G: overrides / specialization
cells['g_negative'] = """
module mid #(parameter int P = 8'h07)(output logic o);
  localparam int NEG = -3;
  function automatic bit [P-1:0][15:0] flp(int n);
    bit [P-1:0][15:0] list; list='0; list[0]=16'(n); return list;
  endfunction
  localparam bit [P-1:0][15:0] LP = flp(NEG);
  assign o = LP[0][0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(-2+4)) u2(.o(o2)); endmodule
"""
cells['g_threeinst'] = """
module mid #(parameter int P = 8'h07)(output logic o);
  function automatic bit [P-1:0][15:0] flp(int n);
    bit [P-1:0][15:0] list; list='0; list[0]=16'(n); return list;
  endfunction
  localparam bit [P-1:0][15:0] LP = flp(P);
  assign o = LP[0][0];
endmodule
module top;
  logic o1,o2,o3,o4,o5,o6,o7;
  mid #(.P(2))          u1(.o(o1));
  mid #(.P(2))          u2(.o(o2));
  mid #(.P(8'h03))      u3(.o(o3));
  mid #(.P(32'hA))      u4(.o(o4));
  mid #(.P(8'o17))      u5(.o(o5));
  mid #(.P(4'b0101))    u6(.o(o6));
  mid                   u7(.o(o7));
endmodule
"""
cells['g_nested_inst'] = """
module leaf #(parameter int P = 3)(output logic o);
  function automatic bit [P-1:0][15:0] flp(int n);
    bit [P-1:0][15:0] list; list='0; list[0]=16'(n); return list;
  endfunction
  localparam bit [P-1:0][15:0] LP = flp(P);
  assign o = LP[0][0];
endmodule
module mid #(parameter int M = 8'h05)(output logic o);
  leaf #(.P(M)) u (.o(o));
endmodule
module top; logic o1,o2; mid #(.M(2)) u1(.o(o1)); mid #(.M(8'h03)) u2(.o(o2)); endmodule
"""
cells['g_unsized'] = """
module mid #(parameter int P = 8'h07)(output logic o);
  function automatic bit [P-1:0][15:0] flp(int n);
    bit [P-1:0][15:0] list; list='0; list[0]=16'(n); return list;
  endfunction
  localparam bit [P-1:0][15:0] LP = flp(P);
  assign o = LP[0][0];
endmodule
module top;
  logic o1,o2,o3;
  mid #(.P('h4))  u1(.o(o1));
  mid #(.P('d5))  u2(.o(o2));
  mid #(.P('o6))  u3(.o(o3));
endmodule
"""
cells['g_stringparam'] = """
module mid #(parameter int P = 8'h07, parameter string S = "x")(output logic o);
  function automatic bit [P-1:0][15:0] flp(int n);
    bit [P-1:0][15:0] list; list='0; list[0]=16'(n); return list;
  endfunction
  localparam bit [P-1:0][15:0] LP = flp(P);
  assign o = LP[0][0];
endmodule
module top; logic o1,o2; mid #(.P(2),.S("a")) u1(.o(o1)); mid #(.P(8'h03),.S("b")) u2(.o(o2)); endmodule
"""
cells['g_realparam_arg'] = """
module mid #(parameter int P = 8'h07)(output logic o);
  localparam real R = 2.5;
  function automatic bit [P-1:0][15:0] flp(int n);
    bit [P-1:0][15:0] list; list='0; list[0]=16'(n); return list;
  endfunction
  localparam bit [P-1:0][15:0] LP = flp(int'(R));
  assign o = LP[0][0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""
cells['g_paramtype_arg'] = """
module mid #(parameter type T = int, parameter int P = 8'h07)(output logic o);
  function automatic bit [P-1:0][15:0] flp(T n);
    bit [P-1:0][15:0] list; list='0; list[0]=16'(n); return list;
  endfunction
  localparam bit [P-1:0][15:0] LP = flp(P);
  assign o = LP[0][0];
endmodule
module top; logic o1,o2; mid #(.T(int),.P(2)) u1(.o(o1)); mid #(.T(byte),.P(8'h03)) u2(.o(o2)); endmodule
"""
cells['g_symbolic_rhs_param'] = """
module mid #(parameter int P = 8'h07)(output logic o);
  function automatic int sym(int n); return n; endfunction
  localparam int S = sym(P);
  function automatic bit [P-1:0][15:0] flp(int n);
    bit [P-1:0][15:0] list; list='0; list[0]=16'(n); return list;
  endfunction
  localparam bit [P-1:0][15:0] LP = flp(S);
  assign o = LP[0][0];
endmodule
module top; logic o1,o2; mid #(.P(2)) u1(.o(o1)); mid #(.P(8'h03)) u2(.o(o2)); endmodule
"""

os.makedirs(OUT, exist_ok=True)
for name, src in cells.items():
    d = os.path.join(OUT, name)
    os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'top.sv'), 'w').write(src.lstrip('\n'))
print(f"cells={len(cells)} -> {OUT}")
