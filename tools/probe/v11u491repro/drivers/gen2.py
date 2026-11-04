import os
R='/tmp/wt_v11u491/tools/probe/v11u491repro/cases'
def mk(g,n,law,src):
    d=os.path.join(R,g,n); os.makedirs(d,exist_ok=True)
    open(os.path.join(d,'dut.sv'),'w').write('// § %s\n%s'%(law,src.lstrip('\n')))
U='ovUnsizedBasedActualForm491'
mk('VC','vc01',U,"""
module m #(parameter logic [7:0] A = 4) (output logic [7:0] o, output logic [15:0] p);
assign o = A; assign p = A;
endmodule
module top; logic [7:0] o; logic [15:0] p; m #(.A('hFFF)) u(o, p); endmodule
""")
mk('VC','vc02',U,"""
module s #(parameter X = 1) (output logic [7:0] o); assign o = X; endmodule
module m #(parameter A = 4) (output logic [7:0] o); s #(.X(A)) c(o); endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
""")
mk('VC','vc03',U,"""
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o, o2; m #(.A('h5)) u(o); m #(.A('h5)) u2(o2); endmodule
""")
mk('VC','vc04',U,"""
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o, o2; m #(.A('h5)) u(o); m u2(o2); endmodule
""")
mk('VC','vc05',U,"""
module m #(parameter A = 4) (output logic [7:0] o);
for (genvar i = 0; i < A; i++) begin : g assign o[i] = 1'b1; end
endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
""")
mk('VC','vc06',U,"""
module m #(parameter logic [7:0] A = 4) (output logic [7:0] o); localparam B = A + 1; assign o = B; endmodule
module top; logic [7:0] o; m #(.A('hFFF)) u(o); endmodule
""")
mk('VC','vc07',U,"""
module m #(parameter int unsigned A = 4) (output logic [7:0] o); always_comb o = A; endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
""")
mk('VC','vc08',U,"""
module m #(parameter int A = 4) (output logic [7:0] o); function automatic int f(int x); return x + A; endfunction assign o = f(1); endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
""")
mk('VC','vc09',U,"""
module m #(parameter A = 4) (output logic [7:0] o); assign o = A[2:0]; endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
""")
mk('VC','vc10',U,"""
module m #(parameter A = 4) (output logic [7:0] o); assign o = {A}; endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
""")
mk('VC','vc11',U,"""
module m #(parameter A = 4) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module top; logic [7:0] o; m #(.A('b101)) u(o); endmodule
""")
mk('VC','vc12',U,"""
module m #(parameter A = 4'd3) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
""")
S='ovSizedActualMoreBases491'
mk('VC','vc13',S,"""
module s #(parameter X = 1) (output logic [7:0] o); assign o = X; endmodule
module m #(parameter A = 4'd15) (output logic [7:0] o); s #(.X(A)) c(o); endmodule
module top; logic [7:0] o; m #(.A(4'b1010)) u(o); endmodule
""")
mk('VC','vc14',S,"""
module m #(parameter A = 4'd15) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o, o2; m #(.A(4'b1010)) u(o); m #(.A(4'b1010)) u2(o2); endmodule
""")
mk('VC','vc15',S,"""
module m #(parameter A = 4'd15) (output logic [7:0] o); for (genvar i = 0; i < A; i++) begin : g end assign o = 0; endmodule
module top; logic [7:0] o; m #(.A(4'b0011)) u(o); endmodule
""")
mk('VC','vc16',S,"""
module m #(parameter A = 4'd15, parameter B = A) (output logic [7:0] o); assign o = B; endmodule
module top; logic [7:0] o; m #(.A(4'b1010)) u(o); endmodule
""")
T='bitNegTypedOperandSize491'
mk('VC','vc17',T,"""
module m #(parameter type T = logic [7:0], parameter T A = 4'd4) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module top; logic [7:0] o; m u(o); endmodule
""")
mk('VC','vc18',T,"""
typedef enum logic [3:0] {E0, E1} e_t;
module m #(parameter e_t A = E1) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module top; logic [7:0] o; m u(o); endmodule
""")
mk('VC','vc19',T,"""
module m #(parameter bit [7:0] A = 4'd4) (output logic [7:0] o); localparam B = ~A; localparam C = B + 1; assign o = C; endmodule
module top; logic [7:0] o; m u(o); endmodule
""")
mk('VC','vc20',T,"""
module m #(parameter bit [7:0] A = 4'd4) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module top; logic [7:0] o, o2; m u(o); m #(.A(4'd9)) u2(o2); endmodule
""")
D='unboundedDepBesideDefparam491'
mk('VC','vc21',D,"""
module m #(parameter logic [3:0] A = 4'd15, parameter X = 1) (output logic [7:0] o); localparam B = A + 4'd1; assign o = B; endmodule
module top; logic [7:0] o; m u(o); defparam u.X = 2; endmodule
""")
mk('VC','vc22',D,"""
module m #(parameter A = 4'd15, parameter X = 1) (output logic [7:0] o); localparam B = A + 4'd1; assign o = B + X; endmodule
module top; logic [7:0] o; m u(o); defparam u.X = 2; endmodule
""")
mk('VC','vc23',D,"""
module m #(parameter A = 4'd15, parameter X = 1) (output logic [7:0] o); localparam B = A + 4'd1; localparam D = B - 4'd1; assign o = D; endmodule
module top; logic [7:0] o; m u(o); defparam u.X = 2; endmodule
""")
mk('VC','vc24',D,"""
module m #(parameter A = 4'd15, parameter X = 1) (output logic [7:0] o); localparam B = A + 4'd1; localparam C = ~B; assign o = C; endmodule
module top; logic [7:0] o; m u(o); defparam u.X = 2; endmodule
""")
mk('VC','vc25',D,"""
module m #(parameter A = 4'd15, parameter X = 1) (output logic [7:0] o); localparam B = A + 4'd1; assign o = B; endmodule
module top; logic [7:0] o, o2; m u(o); m u2(o2); defparam u.X = 2; defparam u2.A = 4'd2; endmodule
""")
Z='unboundedSubSize64_491'
mk('VC','vc26',Z,"""
module m #(parameter logic [3:0] A = 4'd3) (output logic [7:0] o); localparam B = A - 4'd1; assign o = B + 1; endmodule
module top; logic [7:0] o; m u(o); endmodule
""")
mk('VC','vc27',Z,"""
module m #(parameter A = 4'd3) (output logic [7:0] o); localparam B = A - 4'd1; localparam C = B + 4'd1; assign o = C; endmodule
module top; logic [7:0] o; m u(o); endmodule
""")
mk('VC','vc28',Z,"""
module m #(parameter A = 4'd3) (output logic [7:0] o); localparam B = A - 4'd1; localparam C = {B}; assign o = C + 1; endmodule
module top; logic [7:0] o; m u(o); endmodule
""")
mk('VC','vc29',Z,"""
module m #(parameter A = 4'd3) (output logic [7:0] o); localparam B = A - 4'd1; localparam C = ~B; assign o = C; endmodule
module top; logic [7:0] o; m u(o); endmodule
""")
mk('VC','vc30',Z,"""
module m #(parameter A = 4'd3) (output logic [7:0] o); localparam B = A - 4'd1; assign o = B; endmodule
module top; logic [7:0] o, o2; m u(o); m #(.A(4'd9)) u2(o2); endmodule
""")
N='bitNegBareNameActual491'
mk('VC','vc31',N,"""
module m #(parameter A = 4) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module top; localparam P = 5; logic [7:0] o; m #(.A(P)) u(o); m #(.A(P+0)) u2(); endmodule
""")
mk('VC','vc32',N,"""
module m #(parameter logic [7:0] A = 4) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module top; localparam P = 4'd5; logic [7:0] o; m #(.A(P)) u(o); endmodule
""")
mk('VC','vc33',N,"""
module m #(parameter A = 4) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module top; localparam P = 'h5; logic [7:0] o; m #(.A(P)) u(o); endmodule
""")
mk('VC','vc34',N,"""
module m #(parameter A = 4) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module top; localparam P = 5; localparam int Q = 9; logic [7:0] o;
m #(.A(Q)) u(o);
endmodule
""")
