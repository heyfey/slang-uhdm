#!/usr/bin/env python3
"""r11u233: mkcases_s.py: writes cases/S (the parse-view $size laws of pass 228: § parseViewSizeExprEval228,
§ pvSizeNoElemDeclines228v) and cases/B (§ sizeBitNetIsVar228).  Every case's first line names its laws."""
import os
R = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'cases')
LS = '// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — '
LB = '// § sizeBitNetIsVar228 § parseViewSizeExprEval228 — '
def w(fam, name, law, desc, body):
    p = os.path.join(R, fam, name); os.makedirs(p, exist_ok=True)
    open(os.path.join(p, 'dut.sv'), 'w').write(law + desc + '\n' + body)
def mod(decls, calls, ports=''):
    outs = ', '.join(f'o{i+1}' for i in range(len(calls)))
    body = f"module dut ({ports}output logic [7:0] {outs});\n{decls}"
    for i, c in enumerate(calls):
        body += f"  wire [7:0] w{i+1} = {c};\n  assign o{i+1} = w{i+1};\n"
    return body + 'endmodule\n'
S = lambda n, d, decls, calls, ports='', pre='': w('S', n, LS, d, pre + mod(decls, calls, ports))
S('s01', 'one-dimensional dynamic, queue and associative operands', '  int d [];\n  int q [$];\n  int a [int];\n', ['$size(d)', '$size(q)', '$size(a)'])
S('s02', 'a dynamic-then-fixed operand (int dq [][3]), both argument forms', '  int dq [][3];\n', ['$size(dq)', '$size(dq, 2)'])
S('s03', 'a queue-then-fixed operand (int qf [$][2]), both argument forms', '  int qf [$][2];\n', ['$size(qf)', '$size(qf, 2)'])
S('s04', 'an associative-then-fixed operand (int af [int][2]), both argument forms', '  int af [int][2];\n', ['$size(af)', '$size(af, 2)'])
S('s05', 'a fixed-then-associative operand (int fa [2][string]), the first dimension in both argument forms', '  int fa [2][string];\n', ['$size(fa)', '$size(fa, 1)'])
S('s06', 'a fixed-fixed-queue operand (logic [3:0] fq [2][3][$]) beside a plain fixed operand', '  logic [3:0] fq [2][3][$];\n  logic [3:0] ff [5];\n', ['$size(fq)', '$size(fq, 2)', '$size(ff)'])
S('s07', 'a typedef\'d element (nib_t a [5]) in both argument forms', '  typedef logic [3:0] nib_t;\n  nib_t a [5];\n', ['$size(a)', '$size(a, 2)'])
S('s08', 'a typedef\'d unpacked array and a typedef\'d packed 2-D vector', '  typedef logic [3:0] arr_t [5];\n  typedef logic [3:0][1:0] pk_t;\n  arr_t a;\n  pk_t b;\n', ['$size(a)', '$size(b)', '$size(b, 2)'])
S('s09', 'a typedef\'d bit packed 2-D variable', '  typedef bit [3:0][1:0] bp_t;\n  bp_t b;\n', ['$size(b)', '$size(b, 2)'])
S('s10', 'the dimension a parameter ($size(m, D))', '  localparam int D = 2;\n  logic [3:0] m [5][6];\n', ['$size(m, D)', '$size(m, D + 1)'])
w('S', 's11', LS, 'the dimension a genvar in a generate-for block ($size(m, i))',
  "module dut (output logic [7:0] o [3]);\n  logic [3:0] m [5][6];\n  for (genvar i = 1; i <= 3; i++) begin : g\n    wire [7:0] w = $size(m, i);\n    assign o[i-1] = w;\n  end\nendmodule\n")
S('s12', 'real, enum and struct elements in both argument forms', '  typedef enum logic [2:0] {A, B, C} e_t;\n  typedef struct packed { logic [2:0] a; logic b; } s_t;\n  real ra [4];\n  e_t ea [3];\n  s_t sa [2];\n', ['$size(ra)', '$size(ea, 2)', '$size(sa, 2)', '$size(ra, 1)'])
S('s13', 'reg element and a signed narrow target', '  reg [3:0] rg [2][3];\n', ['$size(rg)', '$size(rg, 3)'])
w('S', 's14', LS, 'a signed narrow target that the count overflows, and an unsigned one',
  "module dut (output logic [2:0] o1, o2);\n  logic [1:0][4:0] x;\n  wire signed [2:0] w1 = $size(x, 2);\n  wire [2:0] w2 = $size(x, 2);\n  assign o1 = w1; assign o2 = w2;\nendmodule\n")
w('S', 's15', LS, 'controls the law leaves: a variable initializer and an assign statement (bytes must not move) beside a net declaration',
  "module dut (output logic [7:0] o1, o2, o3);\n  bit [3:0][1:0] b;\n  logic [7:0] v = $size(b);\n  wire [7:0] w2;\n  assign w2 = $size(b);\n  wire [7:0] w3 = $size(b);\n  assign o1 = v; assign o2 = w2; assign o3 = w3;\nendmodule\n")
S('s16', 'a net array operand (wire [3:0] na [3][2])', '  wire [3:0] na [3][2];\n', ['$size(na)', '$size(na, 2)', '$size(na, 3)'])
S('s17', 'chandle and event array operands', '  chandle ca [2];\n  event ev [3];\n', ['$size(ca)', '$size(ev)'])
w('S', 's18', LS, 'the call in a generate block, the operand a module-level variable shadowed by a local of the block',
  "module dut (output logic [7:0] o1, o2);\n  bit [3:0][1:0] x;\n  if (1) begin : g\n    bit [2:0][4:0] x;\n    wire [7:0] w = $size(x);\n    assign o1 = w;\n  end\n  wire [7:0] w2 = $size(x);\n  assign o2 = w2;\nendmodule\n")
w('S', 's19', LS, 'the call in a generate block, the operand a module-level bit vector of the same name as a parameter of a child',
  "module sub #(parameter int x = 9) (output logic [7:0] o);\n  bit [5:0][1:0] y;\n  wire [7:0] w = $size(y);\n  assign o = w;\nendmodule\nmodule dut (output logic [7:0] o1, o2);\n  bit [3:0][1:0] y;\n  if (1) begin : g\n    wire [7:0] w = $size(y);\n    assign o1 = w;\n  end\n  sub u (.o(o2));\nendmodule\n")
S('s20', 'a signed 2-D packed operand and a uwire target', '  logic signed [3:0][1:0] sx;\n', ['$size(sx)', '$size(sx, 2)'])
w('S', 's21', LS, 'an interface body and a program body with fixed-then-queue and plain fixed operands',
  "interface bus;\n  bit [3:0][1:0] x;\n  int qq [2][$];\n  wire [7:0] w1 = $size(x);\n  wire [7:0] w2 = $size(qq, 1);\nendinterface\nprogram prg;\n  bit [2:0][1:0] y;\n  wire [7:0] w3 = $size(y);\nendprogram\nmodule dut (output logic [7:0] o1, o2);\n  bus b ();\n  prg p ();\n  assign o1 = b.w1; assign o2 = b.w2;\nendmodule\n")
S('s22', 'a two-dimensional unpacked string array and a byte array', '  string st [2][3];\n  byte by [4];\n', ['$size(st)', '$size(st, 2)', '$size(by)', '$size(by, 2)'])
S('s23', 'the last dimension of a one-unpacked one-packed operand, and a 3-D mixed operand read at each dimension', '  logic [3:0] m [5];\n  logic [2:0][1:0] m3 [4];\n', ['$size(m, 2)', '$size(m3, 1)', '$size(m3, 2)', '$size(m3, 3)'])
S('s24', 'a class-handle array and a virtual-interface-free packed union', "  typedef union packed { logic [7:0] a; logic [3:0][1:0] b; } u_t;\n  u_t ua [3];\n  u_t us;\n", ['$size(ua)', '$size(ua, 2)', '$size(us)'])
w('S', 's25', LS, 'the operand dimension from a package parameter and a forward-declared typedef',
  "package p;\n  localparam int W = 6;\n  typedef logic [W-1:0][1:0] t_t;\nendpackage\nmodule dut (output logic [7:0] o1, o2);\n  p::t_t a;\n  bit [p::W-1:0][2:0] b;\n  wire [7:0] w1 = $size(a);\n  wire [7:0] w2 = $size(b);\n  assign o1 = w1; assign o2 = w2;\nendmodule\n")
# bit-net law
B = lambda n, d, body: w('B', n, LB, d, body)
B('b01', 'an ANSI bit net port in both argument forms', "module sub (input bit [3:0][1:0] pp, output logic [7:0] o1, o2);\n  wire [7:0] w1 = $size(pp, 1);\n  wire [7:0] w2 = $size(pp, 2);\n  assign o1 = w1; assign o2 = w2;\nendmodule\nmodule dut (input bit [3:0][1:0] i, output logic [7:0] o1, o2);\n  sub u (.pp(i), .o1(o1), .o2(o2));\nendmodule\n")
B('b02', 'a typedef\'d bit net port', "typedef bit [3:0][1:0] bp_t;\nmodule sub (input bp_t pp, output logic [7:0] o1);\n  wire [7:0] w1 = $size(pp);\n  assign o1 = w1;\nendmodule\nmodule dut (input bp_t i, output logic [7:0] o1);\n  sub u (.pp(i), .o1(o1));\nendmodule\n")
B('b03', 'a one-dimensional signed bit net port and a one-bit bit net port', "module sub (input bit signed [7:0] ps, input bit [0:0] sc, output logic [7:0] o1, o2);\n  wire [7:0] w1 = $size(ps);\n  wire [7:0] w2 = $size(sc);\n  assign o1 = w1; assign o2 = w2;\nendmodule\nmodule dut (input bit signed [7:0] i, input bit [0:0] j, output logic [7:0] o1, o2);\n  sub u (.ps(i), .sc(j), .o1(o1), .o2(o2));\nendmodule\n")
B('b04', 'an unpacked array of bit on a port (the law does not apply: control)', "module sub (input bit [3:0] pp [2], output logic [7:0] o1, o2);\n  wire [7:0] w1 = $size(pp);\n  wire [7:0] w2 = $size(pp, 2);\n  assign o1 = w1; assign o2 = w2;\nendmodule\nmodule dut (input bit [3:0] i [2], output logic [7:0] o1, o2);\n  sub u (.pp(i), .o1(o1), .o2(o2));\nendmodule\n")
B('b05', 'a bit net port of an interface, read in the interface and in a generate block of the child', "interface bus (input bit [3:0][1:0] ib);\n  wire [7:0] w1 = $size(ib);\nendinterface\nmodule sub (input bit [2:0][1:0] pp, output logic [7:0] o1);\n  if (1) begin : g\n    wire [7:0] w = $size(pp);\n    assign o1 = w;\n  end\nendmodule\nmodule dut (input bit [3:0][1:0] i, output logic [7:0] o1, o2);\n  bus b (.ib(i));\n  sub u (.pp(i[2:0]), .o1(o1));\n  assign o2 = b.w1;\nendmodule\n")
B('b06', 'a non-ANSI bit net port and an input var bit port (a variable: control)', "module sub (pp, pv, o1, o2);\n  input bit [3:0][1:0] pp;\n  input var bit [3:0][1:0] pv;\n  output logic [7:0] o1, o2;\n  wire [7:0] w1 = $size(pp);\n  wire [7:0] w2 = $size(pv);\n  assign o1 = w1; assign o2 = w2;\nendmodule\nmodule dut (input bit [3:0][1:0] i, output logic [7:0] o1, o2);\n  sub u (.pp(i), .pv(i), .o1(o1), .o2(o2));\nendmodule\n")
B('b07', 'a bit-enum-free bit net whose packed element is a typedef of bit [1:0]', "typedef bit [1:0] b2_t;\nmodule sub (input b2_t [3:0] pp, output logic [7:0] o1, o2);\n  wire [7:0] w1 = $size(pp);\n  wire [7:0] w2 = $size(pp, 2);\n  assign o1 = w1; assign o2 = w2;\nendmodule\nmodule dut (input b2_t [3:0] i, output logic [7:0] o1, o2);\n  sub u (.pp(i), .o1(o1), .o2(o2));\nendmodule\n")

def BT(n, d, typ, decl):
    B(n, d, f"{typ}\nmodule sub (input {decl} pp, output logic [7:0] o1, o2);\n  wire [7:0] w1 = $size(pp);\n  wire [7:0] w2 = $size(pp, 2);\n  assign o1 = w1; assign o2 = w2;\nendmodule\nmodule dut (input {decl} i, output logic [7:0] o1, o2);\n  sub u (.pp(i), .o1(o1), .o2(o2));\nendmodule\n")
BT('b08', 'a typedef of bit [1:0] used whole with a second packed dimension written on the typedef', 'typedef bit [3:0][1:0] b8_t;', 'b8_t')
BT('b09', 'a typedef of a packed array of a typedef\'d bit vector (typedef b2_t [3:0] b8_t)', 'typedef bit [1:0] b2_t;\ntypedef b2_t [3:0] b8_t;', 'b8_t')
BT('b10', 'a packed array of a typedef\'d scalar bit (typedef bit b1_t; b1_t [3:0][1:0])', 'typedef bit b1_t;', 'b1_t [3:0][1:0]')
BT('b11', 'a packed array of a typedef\'d bit vector with two dimensions written (b2_t [3:0][2:0])', 'typedef bit [1:0] b2_t;', 'b2_t [3:0][2:0]')
BT('b12', 'a packed array of a typedef\'d logic vector (control: not a bit net)', 'typedef logic [1:0] l2_t;', 'l2_t [3:0]')
print('ok')
