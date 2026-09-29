#!/usr/bin/env python3
"""r11u233: mkcases_pnx.py: writes cases/P (§ pkgPatFuncBodyLeftoverNoParent227: a package pattern parameter read whole and
by member inside functions, tasks, class methods, nested calls and default arguments), cases/N (§ newArrayPartSelStripped227:
part selects inside new[...] whose bounds are calls, parameters and other selects, both views) and cases/X (the cross-ground
pairs of the two landings and pass 225's fill laws)."""
import os
R = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'cases')
def w(fam, name, first, body, files=None):
    p = os.path.join(R, fam, name); os.makedirs(p, exist_ok=True)
    open(os.path.join(p, 'dut.sv'), 'w').write(first + '\n' + body)
    for fn, t in (files or {}).items(): open(os.path.join(p, fn), 'w').write(t)
LP = '// § pkgPatFuncBodyLeftoverNoParent227 — '
HEAD = '''package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
'''
KID = '''endpackage
module kid #(
    parameter pk::c_t P = pk::C
) (output logic o);
  localparam pk::in_t S = P.u;
  assign o = 1'b0;
endmodule
module dut(output logic o);
  kid k0 (.o(o));
endmodule
'''
P = lambda n, d, mid, head=HEAD, kid=KID: w('P', n, LP + d, head + mid + kid)
P('p01', 'nested calls: mk() calls inner(), which reads UU whole', '''  function automatic in_t inner();
    return UU;
  endfunction
  function automatic c_t mk();
    c_t c; c.u = inner(); c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
''')
P('p02', 'a default argument: mk(in_t x = UU)', '''  function automatic c_t mk(in_t x = UU);
    c_t c; c.u = x; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
''')
P('p03', 'read whole and by member in one function', '''  function automatic c_t mk();
    c_t c; c.u = UU; c.d = UU.a + UU.b; return c;
  endfunction
  localparam c_t C = mk();
''')
P('p04', 'a task reading UU whole beside the evaluated function (tasks are not evaluated)', '''  task automatic tk(output c_t c);
    c.u = UU; c.d = 1;
  endtask
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
''')
P('p05', 'a class method reading UU whole (not evaluated) beside the evaluated function', '''  class K;
    function c_t m();
      c_t c; c.u = UU; c.d = 3; return c;
    endfunction
  endclass
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
''')
P('p06', 'the function called by two localparams', '''  function automatic c_t mk(int unsigned d);
    c_t c; c.u = UU; c.d = d; return c;
  endfunction
  localparam c_t C = mk(64);
  localparam c_t C2 = mk(65);
''')
P('p07', 'read inside an if and a loop', '''  function automatic c_t mk();
    c_t c;
    c.d = 0;
    if (c.d == 0) c.u = UU;
    for (int i = 0; i < 2; i++) c.d += 32;
    return c;
  endfunction
  localparam c_t C = mk();
''')
P('p08', 'a function of another package reading pk::UU, called from that package', '''endpackage
package pk2;
  function automatic pk::c_t mk();
    pk::c_t c; c.u = pk::UU; c.d = 64; return c;
  endfunction
  localparam pk::c_t C = mk();
''', kid=KID.replace('pk::C\n', 'pk2::C\n'))
P('p09', 'a typed pattern parameter (UU = in_t\'{...}) read whole in the function', '''  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
''', head=HEAD.replace("localparam in_t UU = '{a: 11, b: 22};", "localparam in_t UU = in_t'{a: 11, b: 22};"))
P('p10', 'a positional pattern parameter read whole in the function', '''  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
''', head=HEAD.replace("'{a: 11, b: 22}", "'{11, 22}"))
P('p11', 'read whole through a local variable copy', '''  function automatic c_t mk();
    c_t c; in_t t; t = UU; c.u = t; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
''')
P('p12', 'read whole in a function called from a module parameter default (the package holds no localparam call)', '''  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = '{u: '{a: 1, b: 2}, d: 3};
''', kid=KID.replace('parameter pk::c_t P = pk::C', 'parameter pk::c_t P = pk::mk()'))
LN = '// § newArrayPartSelStripped227 — '
def N(n, d, stmts, decls='  logic [7:0] v; int k; logic [7:0] w;\n', pre=''):
    w('N', n, LN + d, f'''package p;
{pre}class c;
{decls}  function void f();
    int la[];
{stmts}  endfunction
endclass
endpackage
module top; endmodule
''')
N('n01', 'part-select bounds that are calls', '    la = new[v[g(2):0]];\n    la = new[v[k +: g(1)]];\n    la = new[v[g(k) +: 2]];\n', pre='function automatic int g(int a); return a + 1; endfunction\n')
N('n02', 'part-select bounds that are parameters', '    la = new[v[P-1:0]];\n    la = new[v[k +: P]];\n    la = new[v[P -: 2]];\n', pre='localparam int P = 3;\n')
N('n03', 'part-select bounds that are other selects', '    la = new[v[w[2:0] +: 2]];\n    la = new[v[w[1] +: 2]];\n    la = new[v[w[k] -: 1]];\n    la = new[v[PA[1]:0]];\n', pre='localparam logic [3:0] PA = 4\'b0110;\n')
N('n04', 'part-select bounds that are class members through this', '    la = new[v[this.k +: 2]];\n    la = new[v[this.w[k] -: 2]];\n')
N('n05', 'two part selects in an operation and a part select inside a concatenation', '    la = new[v[k +: 2] + w[1:0]];\n    la = new[{v[3:0], w[k +: 2]}];\n')
N('n06', 'a part select of a function-local variable with a local index', '    logic [7:0] lv; int j;\n    la = new[lv[j +: 2]];\n    la = new[lv[j -: 1]];\n')
N('n07', 'part-select bounds that are system calls', '    la = new[v[$clog2(k) +: 2]];\n    la = new[v[$bits(w)-1:0]];\n')
LX = '// '
w('X', 'x01', LX + '§ memberInitReducedRootFolds228 § pkgPatFuncBodyLeftoverNoParent227 — a struct parameter whose root is a package pattern read whole by an evaluated function', '''package pk;
  typedef struct packed { int x; int y; } info_t;
  typedef struct packed { info_t u; int z; } c_t;
  localparam info_t UU = '{x: 16, y: 2};
  function automatic c_t mk();
    c_t c; c.u = UU; c.z = 1; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module top(output logic [7:0] o);
  parameter pk::info_t Info = pk::UU;
  localparam int N = Info.x;
  logic [N-1:0] q;
  assign q = '1;
  assign o = 8'(q);
endmodule
''')
w('X', 'x02', LX + '§ memberInitReducedRootFolds228 § pkgPatFuncBodyLeftoverNoParent227 — the struct parameter reads the evaluated function\'s result member (Info = pk::C.u)', '''package pk;
  typedef struct packed { int x; int y; } info_t;
  typedef struct packed { info_t u; int z; } c_t;
  localparam info_t UU = '{x: 16, y: 2};
  function automatic c_t mk();
    c_t c; c.u = UU; c.z = 1; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module top(output logic [7:0] o);
  parameter pk::info_t Info = '{x: pk::C.u.x, y: 0};
  localparam int N = Info.x;
  logic [N-1:0] q;
  assign q = '1;
  assign o = 8'(q);
endmodule
''')
w('X', 'x03', LX + '§ parseViewSizeExprEval228 § fwdPkgRefClassScopeSpan227 — a $size whose operand dimension reads a package parameter computed from a forward package reference', '''package p1;
  localparam int W = $clog2(p2::K);
  typedef struct packed { logic [2:0] x; } s_t;
  localparam s_t S = '{x: p2::E1};
endpackage
package p2;
  typedef enum logic [2:0] {E0, E1, E2} e_t;
  localparam int K = 16;
endpackage
module dut (output logic [7:0] o1, o2);
  bit [p1::W-1:0][1:0] b;
  bit [3:0][p1::S.x:0] c;
  wire [7:0] w1 = $size(b);
  wire [7:0] w2 = $size(c, 2);
  assign o1 = w1; assign o2 = w2;
endmodule
''')
X3B = '''typedef struct packed { int x; } info_t;
module sub #(parameter int Depth = 128) (output logic [Depth-1:0] a);
   assign a = '1;
endmodule
module mid #(parameter info_t Info = '{x: 4}) (output int o);
   localparam int N = Info.x;
   logic [N-1:0] data;
   sub #(.Depth(N)) u (.a(data));
   assign o = int'(data);
endmodule
'''
w('X', 'x04', LX + '§ memberRootOwnInstance228v § initHierFillKept225 § fillSymbolicRootOnly225v — two instances, untyped first then cast, the child writing \'1 onto the member width', X3B + '''module top(output int o1, o2);
   mid #(.Info('{x: 5})) m1 (.o(o1));
   mid #(.Info(info_t'(6))) m2 (.o(o2));
endmodule
''')
w('X', 'x05', LX + '§ memberRootOwnInstance228v § initHierFillKept225 § fillSymbolicRootOnly225v — two instances, cast first then untyped, the child writing \'1 onto the member width', X3B + '''module top(output int o1, o2);
   mid #(.Info(info_t'(6))) m1 (.o(o1));
   mid #(.Info('{x: 5})) m2 (.o(o2));
endmodule
''')
w('X', 'x06', LX + '§ memberRootOwnInstance228v § initHierFillKept225 § fillSymbolicRootOnly225v — the parenthesized cast root beside an untyped one (fillSymbolicRootOnly225v does not read through parentheses)', X3B + '''module top(output int o1, o2);
   mid #(.Info((info_t'(6)))) m1 (.o(o1));
   mid #(.Info('{x: 5})) m2 (.o(o2));
endmodule
''')

w('X', 'x07', LX + '§ memberRootOwnInstance228v § memberInitReducedRootFolds228 — two parent instances with the same member value, untyped then cast (the child bodies may be shared)', X3B + '''module top(output int o1, o2);
   mid #(.Info('{x: 5})) m1 (.o(o1));
   mid #(.Info(info_t'(5))) m2 (.o(o2));
endmodule
''')
w('X', 'x08', LX + '§ memberRootOwnInstance228v § memberInitReducedRootFolds228 — a three-level chain: top > mid > sub > leaf, the leaf range read through two int overrides, mid instances untyped then cast', '''typedef struct packed { int x; } info_t;
module leaf #(parameter int D2 = 8) (output logic [D2-1:0] a);
   assign a = '0;
endmodule
module sub #(parameter int Depth = 128) (output logic [Depth-1:0] a);
   leaf #(.D2(Depth)) l (.a(a));
endmodule
module mid #(parameter info_t Info = '{x: 4}) (output int o);
   localparam int N = Info.x;
   logic [N-1:0] data;
   sub #(.Depth(N)) u (.a(data));
   assign o = int'(data);
endmodule
module top(output int o1, o2);
   mid #(.Info('{x: 5})) m1 (.o(o1));
   mid #(.Info(info_t'(6))) m2 (.o(o2));
endmodule
''')
w('X', 'x09', LX + '§ memberRootOwnInstance228v § memberInitReducedRootFolds228 — the child instantiated from a generate block of the parent, parent instances untyped then cast', '''typedef struct packed { int x; } info_t;
module sub #(parameter int Depth = 128) (output logic [Depth-1:0] a);
   assign a = '0;
endmodule
module mid #(parameter info_t Info = '{x: 4}) (output int o);
   localparam int N = Info.x;
   logic [N-1:0] data;
   if (1) begin : g
      sub #(.Depth(N)) u (.a(data));
   end
   assign o = int'(data);
endmodule
module top(output int o1, o2);
   mid #(.Info('{x: 5})) m1 (.o(o1));
   mid #(.Info(info_t'(6))) m2 (.o(o2));
endmodule
''')
print('ok')
