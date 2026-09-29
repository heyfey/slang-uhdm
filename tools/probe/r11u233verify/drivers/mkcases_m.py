#!/usr/bin/env python3
"""r11u233: mkcases_m.py: writes cases/M (the member-root laws of pass 228: § memberInitReducedRootFolds228 with
§ memberRootFoldShapes228v and § memberRootOwnInstance228v).  Every case's first line names its laws.  Paths from the
repo (this file's location); writes nothing else."""
import os, itertools
D = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'cases', 'M')
L = '// § memberInitReducedRootFolds228 § memberRootFoldShapes228v § memberRootOwnInstance228v — '
SUB = '''typedef struct packed { int x; } info_t;
module sub #(parameter info_t Info = %s) (output logic [7:0] o);
   localparam int N = Info.x;
   logic [N-1:0] q;
   assign q = '1;
   assign o = 8'(q);
endmodule
'''
def w(name, desc, body):
    p = os.path.join(D, name); os.makedirs(p, exist_ok=True)
    open(os.path.join(p, 'dut.sv'), 'w').write(L + desc + '\n' + body)
# three instances of one definition, three root shapes (untyped pattern, plain integer, cast) in every order
shapes = {'P': "'{x: 5}", 'I': '6', 'C': "info_t'(7)"}
for i, perm in enumerate(itertools.permutations('PIC')):
    insts = '\n'.join(f"   sub #(.Info({shapes[s]})) u{k+1} (.o(o{k+1}));" for k, s in enumerate(perm))
    w(f'm{i+1:02d}', f'three instances in the order {"".join(perm)} (P untyped pattern, I integer, C cast) of a child with an untyped default',
      SUB % "'{x: 4}" + f'module top(output logic [7:0] o1, o2, o3);\n{insts}\nendmodule\n')
w('m07', 'a cast default, the first instance an untyped override, the second the default (the definition listing reads the default)',
  SUB % "info_t'(4)" + "module top(output logic [7:0] o1, o2);\n   sub #(.Info('{x: 5})) u1 (.o(o1));\n   sub u2 (.o(o2));\nendmodule\n")
w('m08', 'an array of instances with an untyped override beside a single cast instance',
  SUB % "'{x: 4}" + "module top(output logic [7:0] o1 [2], output logic [7:0] o2);\n   sub #(.Info('{x: 5})) ua [1:0] (.o(o1));\n   sub #(.Info(info_t'(6))) ub (.o(o2));\nendmodule\n")
w('m09', 'generate-for instances whose one override expression selects an untyped pattern on i==0 and a cast otherwise',
  SUB % "'{x: 4}" + "module top(output logic [7:0] o [2]);\n   for (genvar i = 0; i < 2; i++) begin : g\n      sub #(.Info(i == 0 ? '{x: 5} : info_t'(6))) u (.o(o[i]));\n   end\nendmodule\n")
w('m10', 'an override chain across two instances of the parent: mid m1 passes an untyped pattern, m2 a cast',
  SUB % "'{x: 4}" + "module mid #(parameter info_t PI = info_t'(1)) (output logic [7:0] o);\n   sub #(.Info(PI)) u (.o(o));\nendmodule\nmodule top(output logic [7:0] o1, o2);\n   mid #(.PI('{x: 5})) m1 (.o(o1));\n   mid #(.PI(info_t'(6))) m2 (.o(o2));\nendmodule\n")
w('m11', 'an override chain across three parent levels, two branches (untyped pattern then cast)',
  SUB % "'{x: 4}" + "module b #(parameter info_t PB = info_t'(1)) (output logic [7:0] o);\n   sub #(.Info(PB)) u (.o(o));\nendmodule\nmodule a #(parameter info_t PA = info_t'(1)) (output logic [7:0] o);\n   b #(.PB(PA)) ub (.o(o));\nendmodule\nmodule top(output logic [7:0] o1, o2);\n   a #(.PA(info_t'(6))) a1 (.o(o1));\n   a #(.PA('{x: 5})) a2 (.o(o2));\nendmodule\n")
w('m12', 'defparam overrides: u1 an untyped pattern by defparam, u2 a cast by defparam',
  SUB % "'{x: 4}" + "module top(output logic [7:0] o1, o2);\n   sub u1 (.o(o1));\n   sub u2 (.o(o2));\n   defparam u1.Info = '{x: 5};\n   defparam u2.Info = info_t'(6);\nendmodule\n")
w('m13', 'a function-call root (a constant function building the struct)',
  "typedef struct packed { int x; } info_t;\nfunction automatic info_t mk(int v);\n   mk.x = v;\nendfunction\nmodule top(output logic [7:0] o);\n   parameter info_t Info = mk(16);\n   localparam int N = Info.x;\n   logic [N-1:0] q;\n   assign q = '1;\n   assign o = 8'(q);\nendmodule\n")
w('m14', 'a localparam chain onto the struct member (N = A, A = Info.x), untyped root',
  "typedef struct packed { int x; } info_t;\nmodule top(output logic [7:0] o);\n   parameter info_t Info = '{x: 16};\n   localparam int A = Info.x;\n   localparam int N = A;\n   logic [N-1:0] q;\n   assign q = '1;\n   assign o = 8'(q);\nendmodule\n")
w('m15', 'a member two deep (Info.a.x), untyped nested pattern root',
  "typedef struct packed { int x; } in_t;\ntypedef struct packed { in_t a; int y; } info_t;\nmodule top(output logic [7:0] o);\n   parameter info_t Info = '{a: '{x: 16}, y: 3};\n   localparam int N = Info.a.x;\n   logic [N-1:0] q;\n   assign q = '1;\n   assign o = 8'(q);\nendmodule\n")
w('m16', 'a member three deep (Info.b.a.x), untyped nested pattern root',
  "typedef struct packed { int x; } in_t;\ntypedef struct packed { in_t a; int z; } mid_t;\ntypedef struct packed { mid_t b; int y; } info_t;\nmodule top(output logic [7:0] o);\n   parameter info_t Info = '{b: '{a: '{x: 16}, z: 1}, y: 3};\n   localparam int N = Info.b.a.x;\n   logic [N-1:0] q;\n   assign q = '1;\n   assign o = 8'(q);\nendmodule\n")
w('m17', 'an unpacked struct parameter with an untyped pattern root',
  "typedef struct { int x; int y; } uinfo_t;\nmodule top(output logic [7:0] o);\n   parameter uinfo_t Info = '{x: 16, y: 2};\n   localparam int N = Info.x;\n   logic [N-1:0] q;\n   assign q = '1;\n   assign o = 8'(q);\nendmodule\n")
w('m18', 'a selected side that is a struct parameter (SEL ? B : cast, B untyped)',
  "typedef struct packed { int x; } info_t;\nmodule top(output logic [7:0] o);\n   parameter bit SEL = 1;\n   parameter info_t B = '{x: 16};\n   parameter info_t Info = SEL ? B : info_t'(9);\n   localparam int N = Info.x;\n   logic [N-1:0] q;\n   assign q = '1;\n   assign o = 8'(q);\nendmodule\n")
w('m19', 'a root in a package: Info = pk::BASE, BASE an untyped pattern',
  "package pk;\n   typedef struct packed { int x; } info_t;\n   localparam info_t BASE = '{x: 16};\nendpackage\nmodule top(output logic [7:0] o);\n   parameter pk::info_t Info = pk::BASE;\n   localparam int N = Info.x;\n   logic [N-1:0] q;\n   assign q = '1;\n   assign o = 8'(q);\nendmodule\n")
w('m20', 'a root in a package: Info = pk::BASE, BASE a cast',
  "package pk;\n   typedef struct packed { int x; } info_t;\n   localparam info_t BASE = info_t'(16);\nendpackage\nmodule top(output logic [7:0] o);\n   parameter pk::info_t Info = pk::BASE;\n   localparam int N = Info.x;\n   logic [N-1:0] q;\n   assign q = '1;\n   assign o = 8'(q);\nendmodule\n")
def one(name, desc, root, pre='', typ='typedef struct packed { int x; } info_t;'):
    w(name, desc, f"{typ}\nmodule top(output logic [7:0] o);\n{pre}   parameter info_t Info = {root};\n   localparam int N = Info.x;\n   logic [N-1:0] q;\n   assign q = '1;\n   assign o = 8'(q);\nendmodule\n")
one('m21', 'a concatenation holding a replication', "{{2{8'd0}}, 16'd0, 16'd16}", typ='typedef struct packed { int x; int y; } info_t;')
one('m22', 'an untyped pattern whose member is a constant function call', "'{x: f(16)}", pre='   function automatic int f(int v); return v; endfunction\n')
one('m23', "an untyped pattern whose member reads a cast struct parameter's member", "'{x: B.x}", pre="   parameter info_t B = info_t'(16);\n")
one('m24', 'an arithmetic of a cast struct parameter (B + 0)', 'B + 0', pre="   parameter info_t B = info_t'(16);\n")
one('m25', 'a size cast by a parameter width (W\'(16))', "W'(16)", pre='   localparam int W = 32;\n')
one('m26', 'an untyped pattern whose member is a conditional of casts', "'{x: SEL ? int'(16) : int'(9)}", pre='   parameter bit SEL = 1;\n')
one('m27', 'an untyped pattern whose member is a system call', "'{x: $clog2(65536)}")
one('m28', 'an arithmetic of a system call', '$clog2(65536) + 0')
one('m29', 'an untyped pattern whose member is a unary operator', "'{x: +16}")
one('m30', 'an untyped pattern whose member is a replicated concatenation', "'{x: {2{3'd2}}}")
w('m31', 'an untyped pattern whose inner member is a cast (Info.a.x)',
  "typedef struct packed { int x; } in_t;\ntypedef struct packed { in_t a; int y; } info_t;\nmodule top(output logic [7:0] o);\n   parameter info_t Info = '{a: in_t'(16), y: 0};\n   localparam int N = Info.a.x;\n   logic [N-1:0] q;\n   assign q = '1;\n   assign o = 8'(q);\nendmodule\n")
one('m32', 'an arithmetic of an untyped-pattern struct parameter (B + 0)', 'B + 0', pre="   parameter info_t B = '{x: 16};\n")
one('m33', 'a shift of literals and a name (W << 2)', 'W << 2', pre='   localparam int W = 4;\n')
one('m34', 'an unbased unsized fill root', "'1", typ='typedef struct packed { logic [3:0] x; } info_t;')
one('m35', 'a parenthesized concatenation holding a cast', "({info_t'(16)})")
one('m36', 'a real literal root converted', '16.0')
# the signal in a generate scope, the root in another instance of the definition
w('m37', 'the member signal in a generate block, two instances (untyped, cast)',
  "typedef struct packed { int x; } info_t;\nmodule sub #(parameter info_t Info = '{x: 4}) (output logic [7:0] o);\n   if (1) begin : g\n      localparam int N = Info.x;\n      logic [N-1:0] q;\n      assign q = '1;\n      assign o = 8'(q);\n   end\nendmodule\nmodule top(output logic [7:0] o1, o2);\n   sub #(.Info('{x: 5})) u1 (.o(o1));\n   sub #(.Info(info_t'(6))) u2 (.o(o2));\nendmodule\n")
w('m38', 'the root a struct parameter declared in a generate block of the instance (localparam in g reads the module parameter)',
  "typedef struct packed { int x; } info_t;\nmodule sub #(parameter info_t Info = '{x: 4}) (output logic [7:0] o);\n   if (1) begin : g\n      localparam info_t I2 = Info;\n      localparam int N = I2.x;\n      logic [N-1:0] q;\n      assign q = '1;\n      assign o = 8'(q);\n   end\nendmodule\nmodule top(output logic [7:0] o1, o2);\n   sub #(.Info(info_t'(6))) u1 (.o(o1));\n   sub #(.Info('{x: 5})) u2 (.o(o2));\nendmodule\n")
w('m39', 'a package struct constant read by member in a module (N = pk::INFO.x), untyped pattern',
  "package pk;\n   typedef struct packed { int x; } info_t;\n   localparam info_t INFO = '{x: 16};\nendpackage\nmodule top(output logic [7:0] o);\n   localparam int N = pk::INFO.x;\n   logic [N-1:0] q;\n   assign q = '1;\n   assign o = 8'(q);\nendmodule\n")
w('m40', 'two instances of a child, both untyped overrides with different widths and a cast-default third definition listing',
  SUB % "info_t'(4)" + "module top(output logic [7:0] o1, o2);\n   sub #(.Info('{x: 5})) u1 (.o(o1));\n   sub #(.Info('{x: 7})) u2 (.o(o2));\nendmodule\n")
print('ok')
