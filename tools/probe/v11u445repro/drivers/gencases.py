import os, sys
root = sys.argv[1]
C = {}
def c(g, n, law, body):
    C[(g, n)] = "// § " + law + "\n" + body.strip("\n") + "\n"
B='foreachLoopVarShadowDeclTs445'; MP='foreachLoopVarModParamTs445'; PR='loopVarParamReadUnbound445'
PN='progIfaceParamNoShadow445'; IF='ifaceLoopVarReadBindsDecl445'; PK='pkgSubLoopVarReadBindsDecl445'
# VB: block-local shadow shapes
c('VB','vb01',B,"""
module top;
int arr[4]; int s;
initial for (int i = 0; i < 1; i++) foreach (arr[i]) s = s + i;
endmodule""")
c('VB','vb02',B,"""
module top;
int a[4]; int b[2]; int s;
initial begin int i; foreach (a[i]) foreach (b[i]) s = s + i; end
endmodule""")
c('VB','vb03',B,"""
module top;
int arr[4];
typedef struct packed { logic [1:0] f; } st_t;
initial begin st_t i; foreach (arr[i]) arr[i] = i; end
endmodule""")
c('VB','vb04',B,"""
module top;
int arr[4]; int s;
initial begin string i; foreach (arr[i]) s = s + i; end
endmodule""")
c('VB','vb05',B,"""
module top;
int arr[4]; int s;
initial begin int i[2]; foreach (arr[i]) s = s + i; end
endmodule""")
c('VB','vb06',B,"""
module top;
int arr[4]; int s;
initial begin event i; foreach (arr[i]) s = s + i; end
endmodule""")
c('VB','vb07',B,"""
module top;
int arr[4]; int s;
initial begin int i; fork foreach (arr[i]) s = s + i; join end
endmodule""")
c('VB','vb08',B,"""
module top;
int arr[4]; int s;
initial begin static int i; foreach (arr[i]) s = s + i; end
endmodule""")
c('VB','vb09',B,"""
module top;
int m[2][3]; int s;
initial begin int j; foreach (m[i, j]) s = s + i + j; end
endmodule""")
c('VB','vb10',B,"""
module top;
int m[2][3]; int s;
initial begin int j; foreach (m[, j]) s = s + j; end
endmodule""")
c('VB','vb11',B,"""
module top;
int aa[string]; int s;
initial begin string i; foreach (aa[i]) s = s + aa[i]; end
endmodule""")
c('VB','vb12',B,"""
module top;
int dq[$]; int da[]; int s;
initial begin int i; foreach (dq[i]) s = s + i; foreach (da[i]) s = s + i; end
endmodule""")
c('VB','vb13',B,"""
module top;
int arr[4]; int s;
initial begin bit signed [5:0] i; foreach (arr[i]) s = s + i; end
endmodule""")
c('VB','vb14',B,"""
module top;
int arr[4]; int s;
initial begin var i; foreach (arr[i]) s = s + i; end
endmodule""")
c('VB','vb15',B,"""
module top;
int arr[4]; int s;
initial begin real i; foreach (arr[i]) s = s + i; end
endmodule""")
c('VB','vb16',B,"""
function automatic int uf();
  int arr[4]; int s;
  begin int i; foreach (arr[i]) s = s + i; end
  return s;
endfunction
module top; int x; initial x = uf(); endmodule""")
c('VB','vb17',B,"""
module sub;
int arr[4]; int s;
for (genvar g = 0; g < 2; g++) begin : gl
  initial begin int i; foreach (arr[i]) s = s + i; end
end
endmodule
module top; sub u(); endmodule""")
c('VB','vb18',B,"""
module top;
int arr[4]; int s; logic clk, rst;
always_ff @(posedge clk) begin int i; if (rst) s <= 0; else foreach (arr[i]) s <= s + i; end
endmodule""")
c('VB','vb19',B,"""
interface ifc;
int arr[4]; int s;
initial begin int i; foreach (arr[i]) s = s + i; end
endinterface
module top; ifc u1(); ifc u2(); endmodule""")
c('VB','vb20',B,"""
module top;
int arr[4]; int s;
task automatic t(input int i); begin foreach (arr[i]) s = s + i; end endtask
endmodule""")
c('VB','vb21',B,"""
module top;
int arr[4]; int s;
initial begin int i; foreach (arr[i]) begin int k; k = i; s = s + k; end end
endmodule""")
c('VB','vb22',B,"""
module top;
int arr[4]; int s;
initial begin int i; i = 5; foreach (arr[i]) s = s + i; s = s + i; end
endmodule""")
c('VB','vb23',B,"""
module top;
logic [3:0] v; int s;
initial begin int i; foreach (v[i]) s = s + i; end
endmodule""")
c('VB','vb24',B,"""
module top;
int arr[4]; int s;
class C; endclass
initial begin C i; foreach (arr[i]) s = s + i; end
endmodule""")
c('VB','vb25',B,"""
module top;
int arr[4]; int s;
initial begin : i foreach (arr[i]) s = s + i; end
endmodule""")
c('VB','vb26',B,"""
module top;
int arr[4]; int s;
initial begin int i; i: foreach (arr[i]) s = s + i; end
endmodule""")
# VM: module parameter shapes
c('VM','vm01',MP,"""
module sub #(parameter int W = 2);
parameter logic [W-1:0] i = 1;
int arr[4]; int s;
initial foreach (arr[i]) s = s + i;
endmodule
module top; sub u1(); sub #(.W(4)) u2(); endmodule""")
c('VM','vm02',MP,"""
module top #(parameter int i = 2);
int arr[4]; int s;
initial foreach (arr[i]) s = s + i;
endmodule""")
c('VM','vm03',MP,"""
module top;
parameter int i = 2;
int arr[4]; int s;
if (1) begin : g
  initial foreach (arr[i]) s = s + i;
end
endmodule""")
c('VM','vm04',MP,"""
module top;
parameter int i = 2;
int arr[4]; int s;
task automatic t; foreach (arr[i]) s = s + i; endtask
endmodule""")
c('VM','vm05',MP,"""
module top;
parameter type i = int;
int arr[4]; int s;
initial foreach (arr[i]) s = s + i;
endmodule""")
c('VM','vm06',MP,"""
module top;
typedef enum logic [1:0] {A, B, C} e_t;
parameter e_t i = B;
int arr[4]; int s;
initial foreach (arr[i]) s = s + i;
endmodule""")
c('VM','vm07',MP,"""
module top;
parameter int i [2] = '{1, 2};
int arr[4]; int s;
initial foreach (arr[i]) s = s + i;
endmodule""")
c('VM','vm08',MP,"""
module top;
parameter string i = "x";
int arr[4]; int s;
initial foreach (arr[i]) s = s + i;
endmodule""")
c('VM','vm09',MP,"""
package pk; parameter int i = 7; endpackage
module top;
import pk::*;
int arr[4]; int s;
initial foreach (arr[i]) s = s + i;
endmodule""")
c('VM','vm10',MP,"""
package pk; parameter int i = 7; endpackage
module top;
import pk::i;
int arr[4]; int s;
initial foreach (arr[i]) s = s + i;
endmodule""")
c('VM','vm11',MP,"""
parameter int i = 7;
module top;
int arr[4]; int s;
initial foreach (arr[i]) s = s + i;
endmodule""")
c('VM','vm12',MP,"""
module top;
parameter int i = 2;
int arr[4]; int s;
for (genvar g = 0; g < 2; g++) begin : gl
  initial foreach (arr[i]) s = s + i;
end
endmodule""")
c('VM','vm13',MP,"""
module top;
parameter int i = 2;
int m[2][3]; int s;
initial foreach (m[i, j]) s = s + i + j;
endmodule""")
c('VM','vm14',MP,"""
module top;
parameter int j = 2;
int m[2][3]; int s;
initial foreach (m[, j]) s = s + j;
endmodule""")
c('VM','vm15',MP,"""
module top;
parameter int i = 2;
int arr[4]; int s;
initial foreach (arr[i]) foreach (arr[i]) s = s + i;
endmodule""")
c('VM','vm16',MP,"""
module top;
parameter int i = 2;
int arr[4]; int s;
always_comb begin s = 0; foreach (arr[i]) s = s + i; end
endmodule""")
c('VM','vm17',MP,"""
module sub;
parameter int i = 2;
int arr[4]; int s;
initial foreach (arr[i]) s = s + i;
endmodule
module top; defparam u.i = 5; sub u(); endmodule""")
c('VM','vm18',MP,"""
module top;
parameter int i = 2;
int arr[4]; int s;
function automatic int f(); int r; foreach (arr[i]) r = r + i; return r; endfunction
assign s = f();
endmodule""")
c('VM','vm19',MP,"""
module top;
parameter i = 4'b0011;
int arr[4]; int s;
initial foreach (arr[i]) s = s + i;
endmodule""")
c('VM','vm20',MP,"""
module top;
parameter int i = 2;
int arr[4]; int s;
initial std::randomize(arr) with { foreach (arr[i]) arr[i] < i; };
endmodule""")
c('VM','vm21',MP,"""
module top;
parameter int i = 2;
int arr[4]; int s;
class C; int a[2]; constraint c { foreach (a[i]) a[i] < i; } endclass
endmodule""")
# VR: with iterators / reads
c('VR','vr01',PR,"""
module top;
parameter int item = 2;
int q[$]; int s;
function automatic int f(); return q.sum() with (item + 1); endfunction
initial s = f();
endmodule""")
c('VR','vr02',PR,"""
module top;
parameter int x = 2;
int q[$]; int r[$];
initial r = q.find(x) with (x > 1);
endmodule""")
c('VR','vr03',PR,"""
module top;
parameter int item = 2;
int q[$]; int s;
if (1) begin : g initial s = q.sum() with (item * 2); end
endmodule""")
c('VR','vr04',PR,"""
module top;
localparam int item = 2;
int q[$]; int s; int r[$];
initial begin r = q.find_index with (item > 0); s = q.sum() with (item); end
endmodule""")
c('VR','vr05',PR,"""
module top;
int item;
int q[$]; int s;
initial s = q.sum() with (item * 2);
endmodule""")
# VP: program / interface parameter shapes
c('VP','vp01',PN,"""
module top; prg p(); endmodule
program prg;
int arr[4]; int s;
parameter type i = int;
initial foreach (arr[i]) s = s + 1;
endprogram""")
c('VP','vp02',PN,"""
interface ifc #(parameter int i = 1);
logic [3:0] sig; int s;
initial foreach (sig[i]) s = s + i;
endinterface
module top; ifc #(.i(3)) u(); endmodule""")
c('VP','vp03',PN,"""
interface ifc;
logic [3:0] sig; int s;
parameter int i = 1;
initial foreach (sig[i]) s = s + i;
endinterface
module top; ifc u1(); ifc u2(); endmodule""")
c('VP','vp04',PN,"""
module top; prg p(); endmodule
program prg;
int da[]; int s;
parameter int i = 1;
initial foreach (da[i]) s = s + i;
endprogram""")
c('VP','vp05',PN,"""
module top; prg p(); endmodule
program prg;
typedef struct { logic [1:0] f; } st_t;
st_t sa[3]; int s;
parameter int i = 1;
initial foreach (sa[i]) s = s + i;
endprogram""")
c('VP','vp06',PN,"""
module top; prg p(); endmodule
program prg;
int arr[4]; int s;
parameter int i = 1;
task automatic t; foreach (arr[i]) s = s + i; endtask
initial t();
endprogram""")
c('VP','vp07',PN,"""
interface ifc;
logic [3:0] sig; int s;
parameter int i = 1;
if (1) begin : g initial foreach (sig[i]) s = s + i; end
endinterface
module top; ifc u(); endmodule""")
c('VP','vp08',PN,"""
module top; prg p(); endmodule
program prg;
int arr[4]; int s;
parameter int i = 1;
initial begin int i; foreach (arr[i]) s = s + i; end
endprogram""")
c('VP','vp09',PN,"""
interface ifc;
logic [3:0] sig; int s;
parameter type i = int;
initial foreach (sig[i]) s = s + 1;
endinterface
module top; ifc u(); endmodule""")
c('VP','vp10',PN,"""
module top; prg p(); endmodule
program prg;
int m[2][3]; int s;
parameter int j = 1;
initial foreach (m[i, j]) s = s + i + j;
endprogram""")
c('VP','vp11',PN,"""
module top; prg #(.i(2)) p(); endmodule
program prg #(parameter int i = 1);
int arr[4]; int s;
initial foreach (arr[i]) s = s + i;
endprogram""")
c('VP','vp12',PN,"""
module top; prg p(); endmodule
program prg;
int aa[string]; int s;
parameter int i = 1;
initial foreach (aa[i]) s = s + aa[i];
endprogram""")
# VI: interface decl binding
c('VI','vi01',IF,"""
interface ifc;
logic [3:0] sig; int s; int i;
initial foreach (sig[i]) s = s + i;
endinterface
module top; ifc u1(); ifc u2(); endmodule""")
c('VI','vi02',IF,"""
interface ifc(input logic [3:0] i);
logic [3:0] sig; int s;
initial foreach (sig[i]) s = s + i;
endinterface
module top; logic [3:0] w; ifc u(w); endmodule""")
c('VI','vi03',IF,"""
interface ifc;
logic [3:0] sig; int s; event i;
initial foreach (sig[i]) s = s + i;
endinterface
module top; ifc u(); endmodule""")
c('VI','vi04',IF,"""
interface ifc;
logic [3:0] sig; int s; int i;
modport mp(input sig, i);
initial foreach (sig[i]) s = s + i;
endinterface
module top; ifc u(); endmodule""")
c('VI','vi05',IF,"""
interface ifc;
logic [3:0] sig; int s; int i;
endinterface
module top; ifc u[2](); endmodule
""".replace("int i;\n","int i;\ninitial foreach (sig[i]) s = s + i;\n"))
c('VI','vi06',IF,"""
interface ifc;
logic [3:0] sig; int s;
initial foreach (sig[i]) s = s + i;
int i;
endinterface
module top; ifc u(); endmodule""")
c('VI','vi07',IF,"""
interface ifc;
logic [3:0] sig; int s;
always_comb begin int i; s = 0; foreach (sig[i]) s = s + i; end
endinterface
module top; ifc u(); endmodule""")
c('VI','vi08',IF,"""
interface ifc;
int q[$]; int r[$];
initial begin int x; r = q.find(x) with (x > 0); end
endinterface
module top; ifc u(); endmodule""")
c('VI','vi09',IF,"""
interface inner; logic [3:0] sig; int s; int i;
initial foreach (sig[i]) s = s + i;
endinterface
interface outer; inner n(); endinterface
module top; outer o(); endmodule""")
c('VI','vi10',IF,"""
module top;
logic [3:0] sig; int s; event i;
initial foreach (sig[i]) s = s + i;
endmodule""")
c('VI','vi11',IF,"""
interface ifc;
logic [3:0] sig; int s; int i;
task automatic t; foreach (sig[i]) s = s + i; endtask
initial t();
endinterface
module top; ifc u(); endmodule""")
# VK: package subroutines
c('VK','vk01',PK,"""
package pk;
int g;
task automatic t(input int i); int arr[4]; foreach (arr[i]) g = g + i; endtask
endpackage
module top; initial pk::t(1); endmodule""")
c('VK','vk02',PK,"""
package pk;
parameter int i = 3;
function automatic int f(); int arr[4]; int s; foreach (arr[i]) s = s + i; return s; endfunction
endpackage
module top; int x = pk::f(); endmodule""")
c('VK','vk03',PK,"""
package pk;
function automatic int f(); int arr[4]; int s; int i; begin foreach (arr[i]) s = s + i; end return s; endfunction
endpackage
module a; int x = pk::f(); endmodule
module top; a u1(); a u2(); endmodule""")
c('VK','vk04',PK,"""
package pk;
function int f(); int arr[4]; int s; static int i; foreach (arr[i]) s = s + i; return s; endfunction
endpackage
module top; int x; initial x = pk::f(); endmodule""")
c('VK','vk05',PK,"""
package pk;
function automatic int f(int x); int q[$]; int r[$]; r = q.find(x) with (x > 1); return r.size(); endfunction
endpackage
module top; int y = pk::f(1); endmodule""")
c('VK','vk06',PK,"""
package pk;
function automatic int f(); int a[4]; int b[2]; int s; int i; foreach (a[i]) foreach (b[j]) s = s + i + j; return s; endfunction
endpackage
module top; int x = pk::f(); endmodule""")
c('VK','vk07',PK,"""
package pk;
function automatic int f(); int m[2][3]; int s; int j; foreach (m[i, j]) s = s + i + j; return s; endfunction
endpackage
module top; int x = pk::f(); endmodule""")
c('VK','vk08',PK,"""
package pk;
function automatic int f(output int i); int arr[4]; int s; i = 0; foreach (arr[i]) s = s + i; return s; endfunction
endpackage
module top; int x, y; initial x = pk::f(y); endmodule""")
c('VK','vk09',PK,"""
package pk;
typedef logic [2:0] n_t;
function automatic int f(); int arr[4]; int s; n_t i; foreach (arr[i]) s = s + i; return s; endfunction
endpackage
module top; int x = pk::f(); endmodule""")
c('VK','vk10',PK,"""
package pk;
function automatic int f(); int arr[4]; int s; int i; foreach (arr[i]) s = s + i; return s; endfunction
endpackage
module top; endmodule""")
c('VK','vk11',PK,"""
function automatic int f(); int arr[4]; int s; int i; foreach (arr[i]) s = s + i; return s; endfunction
module top; int x = f(); endmodule""")
c('VK','vk12',PK,"""
package pk;
function automatic int f(); int arr[4]; int s; int i; fork foreach (arr[i]) s = s + i; join return s; endfunction
endpackage
module top; int x = pk::f(); endmodule""")
for (g, n), t in C.items():
    d = os.path.join(root, g, n); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(t)
print(len(C))
