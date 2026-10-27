import os, sys
root = sys.argv[1]
C = {}
def c(g, n, law, body):
    C[(g, n)] = "// § " + law + "\n" + body.strip("\n") + "\n"
N='nestedLoopVarSkipsOuter445v'
c('VS','vs01',N,"""
interface ifc;
int a[4]; int b[2]; int s;
initial begin int i; foreach (a[i]) foreach (b[i]) s = s + i; end
endinterface
module top; ifc u(); endmodule""")
c('VS','vs02',N,"""
module top;
int a[4]; int b[2]; int s;
task automatic t(input int i); foreach (a[i]) foreach (b[i]) s = s + i; endtask
endmodule""")
c('VS','vs03',N,"""
module top;
int a[4]; int b[2]; int c[3]; int s;
initial begin int i; foreach (a[i]) foreach (b[i]) foreach (c[i]) s = s + i; end
endmodule""")
c('VS','vs04',N,"""
module top;
int m[2][3]; int b[2]; int s;
initial begin int i; foreach (m[i, j]) foreach (b[i]) s = s + i + j; end
endmodule""")
c('VS','vs05',N,"""
module top;
int a[4]; int b[2]; int s;
initial foreach (a[i]) begin int i; foreach (b[i]) s = s + i; end
endmodule""")
c('VS','vs06',N,"""
module top;
int a[4]; int b[2]; int s;
function automatic int f(); int r; foreach (a[i]) foreach (b[i]) r = r + i; return r; endfunction
initial s = f();
endmodule""")
c('VS','vs07',N,"""
interface ifc;
int a[4]; int b[2]; int s;
initial foreach (a[i]) foreach (b[i]) s = s + i;
endinterface
module top; ifc u(); endmodule""")
c('VS','vs08',N,"""
package pk;
function automatic int f(); int a[4]; int b[2]; int s; foreach (a[i]) foreach (b[i]) s = s + i; return s; endfunction
endpackage
module top; int x = pk::f(); endmodule""")
c('VS','vs09',N,"""
module top;
int a[4]; int b[2]; int s;
wire [3:0] i;
initial foreach (a[i]) foreach (b[i]) s = s + i;
endmodule""")
c('VS','vs10',N,"""
module top; prg p(); endmodule
program prg;
int a[4]; int b[2]; int s;
initial begin int i; foreach (a[i]) foreach (b[i]) s = s + i; end
endprogram""")
c('VS','vs11',N,"""
module top;
int a[4]; int b[2]; int s; int i;
task automatic t; foreach (a[i]) foreach (b[i]) s = s + i; endtask
endmodule""")
c('VS','vs12',N,"""
package pk;
function automatic int f(int i); int a[4]; int b[2]; int s; foreach (a[i]) foreach (b[i]) s = s + i; return s; endfunction
endpackage
module top; int x = pk::f(1); endmodule""")
c('VS','vs13',N,"""
module top;
int a[4]; int b[2]; int s; int i;
if (1) begin : g initial foreach (a[i]) foreach (b[i]) s = s + i; end
endmodule""")
c('VS','vs14',N,"""
module top;
parameter int i = 2;
int a[4]; int b[2]; int s;
initial foreach (a[i]) begin s = s + i; foreach (b[i]) s = s + i; end
endmodule""")
c('VS','vs15',N,"""
module top;
int a[4]; int q[$]; int s;
initial foreach (a[i]) s = s + q.sum(i) with (i * 2);
endmodule""")
c('VS','vs16',N,"""
module top;
int a[4]; int q[$]; int s; int i;
initial foreach (a[i]) s = s + q.sum(i) with (i * 2);
endmodule""")
c('VS','vs17',N,"""
module top;
int a[4]; int b[2]; int s;
initial begin int i; foreach (a[i]) begin s = s + i; foreach (b[i]) s = s + i; s = s + i; end end
endmodule""")
c('VS','vs18',N,"""
module sub;
int a[4]; int b[2]; int s;
initial begin int i; foreach (a[i]) foreach (b[i]) s = s + i; end
endmodule
module top; sub u1(); sub u2(); endmodule""")
for (g, n), t in C.items():
    d = os.path.join(root, g, n); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(t)
print(len(C))
