import os
R='/tmp/wt_v11u477/tools/probe/v11u477repro/cases'
def w(g,n,files):
    d=os.path.join(R,g,n); os.makedirs(d,exist_ok=True)
    for f,t in files.items():
        p=os.path.join(d,f); os.makedirs(os.path.dirname(p),exist_ok=True)
        open(p,'w').write(t.lstrip('\n'))
L1='// § parenCallWrittenArgs477\n'
CLS='''class obj;
  function bit compare(obj rhs, obj c = null);
    return 1;
  endfunction
  function int m(int a, int b = 7);
    return a + b;
  endfunction
  static function int sf(int a, int b = 3);
    return a + b;
  endfunction
endclass
'''
VP={
'vp01': L1+'''module top(output int z);
  function automatic int f(int a, int b = 5); return a + b; endfunction
  initial z = (f(.a(1)));
endmodule
''',
'vp02': L1+CLS+'''class comp #(type T = obj);
  T exp;
  function void write(T rec);
    if (((exp.compare(rec)))) $display("x");
  endfunction
endclass
module top;
endmodule
''',
'vp03': L1+'''module top(output int z, output int y);
  logic [7:0] v;
  initial begin z = ($clog2(8)); y = ($bits(v)); end
endmodule
''',
'vp04': L1+'''module top(output int z);
  function automatic int f(int a, int b = 5, int c = 6); return a + b + c; endfunction
  initial z = (f(1, , 3));
endmodule
''',
'vp05': L1+'''module top(input int a, output int z);
  function automatic int f(int x, int y = 2); return x * y; endfunction
  assign z = (f(a)) + 1;
endmodule
''',
'vp06': L1+CLS+'''module top(output int z);
  obj o;
  initial begin o = new; z = (o.m(1, 2)); end
endmodule
''',
'vp07': L1+'''module top(output int z, output int y);
  int q[$];
  string s;
  initial begin z = (q.size()); y = (s.len()); end
endmodule
''',
'vp08': L1+'''package p;
  function automatic int f(int a, int b = 4); return a - b; endfunction
  function automatic int g(int a); return (f(a)); endfunction
endpackage
module top(output int z);
  initial z = p::g(9);
endmodule
''',
'vp09': L1+'''module sub #(parameter int K = 1) (input int a, output int z);
  function automatic int f(int x, int y = K); return x + y; endfunction
  assign z = (f(a));
endmodule
module top(input int a, output int z1, output int z2);
  sub u1(.a(a), .z(z1));
  sub #(.K(3)) u2(.a(a), .z(z2));
endmodule
''',
'vp10': L1+CLS+'''module top(output int z);
  initial z = (obj::sf(1));
endmodule
''',
'vp11': L1+'''module top(output int z);
  function automatic int f(int a, int b = 5); return a + b; endfunction
  function automatic int g(int a); return a; endfunction
  initial z = g((f(1)));
endmodule
''',
'vp12': L1+'''module top(output int z);
  function automatic int f(int a = 1, int b = 5); return a + b; endfunction
  initial z = (f(.b(2)));
endmodule
''',
'vp13': L1+CLS+'''class d extends obj;
  function int m(int a, int b = 9);
    return (super.m(a)) + (this.sf(a));
  endfunction
endclass
module top;
endmodule
''',
'vp14': L1+'''interface ifc(input logic clk);
  function automatic int f(int a, int b = 5); return a + b; endfunction
  int w;
  initial w = (f(2));
endinterface
module top(input logic clk);
  ifc u(clk);
endmodule
''',
'vp15': L1+'''module top(output int z[2]);
  function automatic int f(int a, int b = 5); return a + b; endfunction
  for (genvar i = 0; i < 2; i++) begin : g
    initial z[i] = (f(i));
  end
endmodule
''',
'vp16': L1+'''module top(output int z);
  function automatic int f(int a, int b); return a + b; endfunction
  initial z = (f(1, 2));
endmodule
''',
'vp17': L1+'''module top(output int z);
  import "DPI-C" function int cf(int a, int b = 3);
  initial z = (cf(1));
endmodule
''',
'vp18': L1+'''module top(output int z);
  task automatic t(input int a, output int r, input int b = 4); r = a + b; endtask
  function automatic int f(int a, int b = 5); return a + b; endfunction
  initial begin if ((f(1)) > 2) t(1, z); end
endmodule
''',
}
for n,t in VP.items(): w('VP',n,{'dut.sv':t})
# root-file
L2='// § unitImpRootFileDef477\n'
PK='''package p;
  parameter int W = 4;
  function automatic int pf(int a); return a + 1; endfunction
endpackage
'''
MOD='''module m;
  logic [W-1:0] x;
  initial x = pf(1);
endmodule
'''
w('VR','vr01',{'dut.sv':L2+PK+'`include "inc.svh"\nimport p::*;\nmodule top;\n  m u();\nendmodule\n','inc.svh':MOD})
w('VR','vr02',{'dut.sv':L2+PK+'`include "imp.svh"\nmodule top;\n  m u();\nendmodule\n'+MOD,'imp.svh':'import p::*;\n'})
w('VR','vr03',{'dut.sv':L2+PK+'`include "a.svh"\nmodule top;\n  m u();\nendmodule\n','a.svh':'import p::*;\n`include "b.svh"\n','b.svh':MOD})
w('VR','vr04',{'dut.sv':L2+PK+'import p::*;\n`include "inc.svh"\nmodule top;\n  logic c;\n  ifc u(c);\nendmodule\n','inc.svh':'interface ifc(input logic c);\n  logic [W-1:0] x;\n  initial x = pf(1);\nendinterface\n'})
w('VR','vr05',{'dut.sv':L2+PK+'import p::W;\n`include "inc.svh"\nmodule top;\n  m u();\nendmodule\n','inc.svh':'module m;\n  logic [W-1:0] x;\nendmodule\n'})
w('VR','vr06',{'dut.sv':L2+PK+'package q;\n  parameter int V = 2;\nendpackage\nimport p::*;\n`include "inc.svh"\nmodule top;\n  m u();\nendmodule\n','inc.svh':'import q::*;\nmodule m;\n  logic [W+V-1:0] x;\nendmodule\n'})
w('VR','vr07',{'dut.sv':L2+'`include "inc.svh"\nmodule top;\n  m u();\nendmodule\n'+PK+'import p::*;\n','inc.svh':'module m;\n  logic x;\nendmodule\n'})
w('VR','vr08',{'dut.sv':L2+PK+'`define INC "inc.svh"\nimport p::*;\n`include `INC\nmodule top;\n  m u();\nendmodule\n','inc.svh':MOD})
w('VR','vr09',{'dut.sv':L2+'package p;\n  parameter int W = 4;\nendpackage\nimport p::*;\n`include "inc.svh"\nmodule top;\n  m #(.K(2)) u1();\n  m u2();\nendmodule\n','inc.svh':'module m #(parameter int K = W);\n  logic [K-1:0] x;\n  assign x = W;\nendmodule\n'})
w('VR','vr10',{'dut.sv':L2+PK+'import p::*;\nmodule top;\n  `include "body.svh"\nendmodule\n','body.svh':'  logic [W-1:0] x;\n  initial x = pf(2);\n'})
w('VR','vr11',{'dut.sv':L2+PK+'import p::*;\n`include "inc.svh"\nmodule top;\nendmodule\n','inc.svh':'program prg;\n  int x;\n  initial x = W;\nendprogram\n'})
# __FILE__
L3='// § fileMacroPathNormal477\n'
INC='module m;\n  initial $display("%s", `__FILE__);\nendmodule\n'
TOP='module top;\n  m u();\nendmodule\n'
w('VF','vf01',{'dut.sv':L3+'module top;\n  initial $display("%s %0d", `__FILE__, `__LINE__);\nendmodule\n'})
w('VF','vf02',{'dut.sv':L3+'`include "sub//inc.svh"\n'+TOP,'sub/inc.svh':INC})
w('VF','vf03',{'dut.sv':L3+'`include "../vf03/sub/inc.svh"\n'+TOP,'sub/inc.svh':INC})
w('VF','vf04',{'dut.sv':L3+'`include "./sub/inc.svh"\n'+TOP,'sub/inc.svh':'module m;\n  parameter string F = `__FILE__;\n  initial $display("%s", F);\nendmodule\n'})
w('VF','vf05',{'dut.sv':L3+'`include "./sub/inc.svh"\n'+TOP,'sub/inc.svh':'module m;\n  string s;\n  initial begin s = {`__FILE__, ":x"}; $display(s); end\nendmodule\n'})
w('VF','vf06',{'dut.sv':L3+'`define WHERE `__FILE__\n`include "./sub/inc.svh"\n'+TOP,'sub/inc.svh':'module m;\n  initial $display("%s", `WHERE);\nendmodule\n'})
w('VF','vf07',{'dut.sv':L3+'`include "./sub/./inc.svh"\n'+TOP,'sub/inc.svh':'module m;\n  initial begin\n    $display("%s", `__FILE__); $display("%s", `__FILE__);\n  end\nendmodule\n'})
w('VF','vf08',{'dut.sv':L3+'`include "sub/inc.svh"\n'+TOP,'sub/inc.svh':INC})
# add leaf
L4='// § caAddLeafIntMint477\n'
PA='''package a;
  typedef logic [5:0] t;
  parameter t PA = 6'd33;
  parameter t PB = PA;
endpackage
'''
def mod(body,ports='output logic [7:0] z'):
    return L4+'module top(%s);\n  parameter logic [7:0] P = 8\'d33;\n  parameter logic [7:0] Q = 8\'d5;\n%s\nendmodule\n'%(ports,body)
VA={
'va01': L4+PA+"module top(output logic [5:0] z);\n  import a::*;\n  assign z = PB - 6'd1;\nendmodule\n",
'va02': L4+PA+"module top(output logic [5:0] z);\n  import a::*;\n  assign z = (PB + 6'd1) * 2;\nendmodule\n",
'va03': mod("  assign z = -(P + 8'd1);"),
'va04': mod("  localparam bit C = 1;\n  assign z = C ? P + 8'd1 : 8'd0;"),
'va05': mod("  logic [7:0] v = P + 8'd1;\n  assign z = v;"),
'va06': L4+"module sub(input logic [7:0] i, output logic [7:0] o);\n  assign o = i;\nendmodule\nmodule top(output logic [7:0] z);\n  parameter logic [7:0] P = 8'd33;\n  sub u(.i(P + 8'd1), .o(z));\nendmodule\n",
'va07': mod("  if (1) begin : g\n    assign z = P + 8'd1;\n  end"),
'va08': mod("  parameter int R = 3;\n  logic [R + 4'd1 : 0] x;\n  assign z = x;"),
'va09': mod("  localparam L = P + 8'd1;\n  logic [L:0] y;\n  assign z = L + 0;"),
'va10': mod("  assign z = 8'd1 + 8'd2 + P;"),
'va11': mod("  assign z = P + 8'sd1;"),
'va12': mod("  assign z = {P + 8'd1};"),
'va13': mod("  always_comb z = P + 8'd1;"),
'va14': L4+"package p;\n  parameter logic [3:0] A = 4'd3;\nendpackage\nmodule top(output logic [3:0] z);\n  assign z = p::A + 4'd1;\nendmodule\n",
'va15': mod("  assign z = P + Q;"),
'va16': mod("  assign z = 8'(P + 8'd1);"),
'va17': mod("  assign z = (P + 8'd1) >> 1;"),
'va18': mod("  logic [7:0] arr [0:63];\n  assign z = arr[P + 8'd1];"),
'va19': mod("  assign z = P + 8'd255;"),
'va20': mod("  function automatic logic [7:0] f(logic [7:0] x); return x; endfunction\n  assign z = f(P + 8'd1);"),
'va21': mod("  assign z = P + 8'h1 + 8'd1;"),
'va22': L4+"module sub #(parameter logic [7:0] P = 8'd2) (output logic [7:0] z);\n  assign z = P + 8'd1;\nendmodule\nmodule top(output logic [7:0] z1, output logic [7:0] z2);\n  sub u1(.z(z1));\n  sub #(.P(8'h7)) u2(.z(z2));\nendmodule\n",
'va23': mod("  assign z = ~(P + 8'd1);"),
'va24': mod("  parameter int I = 7;\n  assign z = I + 1;"),
}
for n,t in VA.items(): w('VA',n,{'dut.sv':t})
