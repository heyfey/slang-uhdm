import os, sys
root = sys.argv[1]
C = {}
def c(g, n, law, body):
    C[(g, n)] = "// § " + law + "\n" + body.strip("\n") + "\n"
B='foreachLoopVarShadowDeclTs445'; MP='foreachLoopVarModParamTs445'; PR='loopVarParamReadUnbound445'
PN='progIfaceParamNoShadow445'; IF='ifaceLoopVarReadBindsDecl445'; PK='pkgSubLoopVarReadBindsDecl445'
c('VU','vu01',B,"""
module top; endmodule
program prg;
int arr[4]; int s;
task automatic t; int i; foreach (arr[i]) s = s + i; endtask
endprogram""")
c('VU','vu02',B,"""
module top; endmodule
program prg;
int arr[4]; int s;
function automatic void f(int i); foreach (arr[i]) s = s + i; endfunction
endprogram""")
c('VU','vu03',B,"""
module top; endmodule
interface ifc;
int arr[4]; int s;
task automatic t; begin int i; foreach (arr[i]) s = s + i; end endtask
endinterface""")
c('VU','vu04',PN,"""
module top; endmodule
program prg;
int arr[4]; int s;
parameter int i = 1;
initial foreach (arr[i]) s = s + i;
endprogram""")
c('VU','vu05',IF,"""
module top; endmodule
interface ifc;
logic [3:0] sig; int s; int i;
initial foreach (sig[i]) s = s + i;
endinterface""")
c('VU','vu06',B,"""
module top; endmodule
program prg;
int arr[4]; int s;
initial begin int i; begin foreach (arr[i]) s = s + i; end end
endprogram""")
c('VU','vu07',PN,"""
module top; endmodule
interface ifc;
logic [3:0] sig; int s;
parameter int i = 1;
initial foreach (sig[i]) s = s + i;
endinterface""")
c('VN','vn01',B,"""
module top;
int a[4]; int b[2]; int s; int i;
initial foreach (a[i]) foreach (b[i]) s = s + i;
endmodule""")
c('VN','vn03',B,"""
module top;
int q[$]; int s;
initial begin int i; s = q.sum() with (i * 2); end
endmodule""")
c('VN','vn04',B,"""
module top; prg p1(); prg p2(); endmodule
program prg;
int arr[4]; int s;
initial begin int i; foreach (arr[i]) s = s + i; end
endprogram""")
c('VN','vn06',B,"""
module top;
int arr[4];
function automatic int i(); foreach (arr[i]) arr[i] = 1; return 0; endfunction
endmodule""")
c('VN','vn07',B,"""
module top;
int arr[4]; int s;
task automatic t(ref int i); foreach (arr[i]) s = s + i; endtask
endmodule""")
c('VN','vn08',MP,"""
module top;
int arr[4]; int s;
if (1) begin : g
  localparam int i = 1;
  initial foreach (arr[i]) s = s + i;
end
endmodule""")
c('VN','vn09',IF,"""
interface ifc;
logic [3:0] sig; int s; int i;
final foreach (sig[i]) s = s + i;
endinterface
module top; ifc u(); endmodule""")
c('VN','vn11',PR,"""
module top;
parameter int i = 2;
int arr[4]; int s; int b[4];
initial foreach (arr[i]) begin s = s + b[i]; $display("%0d", i); end
endmodule""")
c('VN','vn13',B,"""
package pk;
function automatic int f(); int a[4]; int b[2]; int s; begin int i; foreach (a[i]) foreach (b[i]) s = s + i; end return s; endfunction
endpackage
module top; int x = pk::f(); endmodule""")
c('VN','vn14',PN,"""
interface ifc;
logic [3:0] sig; int s;
parameter int i = 1;
initial begin int i; foreach (sig[i]) s = s + i; end
endinterface
module top; ifc u(); endmodule""")
c('VN','vn15',PR,"""
module top;
parameter int i = 2;
int arr[4]; int s; logic clk; int y;
assign y = i;
always_ff @(posedge clk) foreach (arr[i]) s <= s + i;
endmodule""")
c('VN','vn16',PR,"""
module sub(input int p); endmodule
module top;
parameter int i = 2;
int arr[4]; int s;
sub u(.p(i));
initial foreach (arr[i]) s = s + i;
endmodule""")
c('VN','vn17',MP,"""
module top;
parameter int i = 2, j = 3;
int m[2][3]; int s;
initial foreach (m[i, j]) s = s + i * j;
endmodule""")
c('VN','vn18',B,"""
module top;
int arr[4]; int s;
initial begin int i; foreach (arr[i]) s += i; end
endmodule""")
c('VN','vn19',B,"""
module top;
int arr[4]; int s;
initial begin int i; foreach (arr[i]) begin i++; s = s + i; end end
endmodule""")
c('VN','vn20',PR,"""
module top;
parameter int i = 2;
logic [3:0] v; int s;
initial foreach (v[i]) s = s + v[i] + i;
endmodule""")
for (g, n), t in C.items():
    d = os.path.join(root, g, n); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(t)
print(len(C))
