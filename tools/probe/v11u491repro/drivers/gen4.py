import os
R='/tmp/wt_v11u491/tools/probe/v11u491repro/cases'
def mk(g,n,law,src):
    d=os.path.join(R,g,n); os.makedirs(d,exist_ok=True)
    open(os.path.join(d,'dut.sv'),'w').write('// § %s\n%s'%(law,src.lstrip('\n')))
U='ovRefUnszBasedFormCopy491v'
mk('VP','vp26',U,"""module g #(parameter Y = 1) (output logic [7:0] o); assign o = Y + 1; endmodule
module s #(parameter X = 1) (output logic [7:0] o); g #(.Y(X)) d(o); endmodule
module m #(parameter A = 4) (output logic [7:0] o); s #(.X(A)) c(o); endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
""")
mk('VP','vp27',U,"""module s #(parameter X = 'h1) (output logic [7:0] o); assign o = X + 1; endmodule
module m #(parameter A = 4) (output logic [7:0] o); s #(.X(A)) c(o); endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
""")
mk('VP','vp28',U,"""module s #(parameter int X = 1) (output logic [7:0] o); assign o = X + 1; endmodule
module m #(parameter A = 4) (output logic [7:0] o); s #(.X(A)) c(o); endmodule
module top; logic [7:0] o; m #(.A('b101)) u(o); endmodule
""")
mk('VP','vp29',U,"""module s #(parameter X = 4'd1) (output logic [7:0] o); assign o = X + 1; endmodule
module m #(parameter logic [7:0] A = 4) (output logic [7:0] o); s #(.X(A)) c(o); endmodule
module top; logic [7:0] o; m #(.A('hAb)) u(o); endmodule
""")
mk('VP','vp30',U,"""module s #(parameter X = 1) (output logic [7:0] o); assign o = X + 1; endmodule
module m #(parameter A = 4) (output logic [7:0] o); s #(.X((A))) c(o); endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
""")
mk('VP','vp31',U,"""module s #(parameter X = 1) (output logic [7:0] o); assign o = X + 1; endmodule
module m #(parameter A = 4) (output logic [7:0] o); s #(.X(A)) c(o); s #(.X(A)) c2(); endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
""")
mk('VP','vp32',U,"""module s #(parameter X = 1) (output logic [7:0] o); assign o = X + 1; endmodule
module m #(parameter A = 4) (output logic [7:0] o); s #(.X(A)) c(o); endmodule
module top; logic [7:0] o, o2; m #(.A('h5)) u(o); m #(.A('h5)) u2(o2); endmodule
""")
mk('VP','vp33',U,"""module s #(parameter X = 1) (output logic [7:0] o); assign o = X + 1; endmodule
module m #(parameter A = 4) (output logic [7:0] o); s #(.X(A)) c(o); endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); defparam u.c.X = 'h3; endmodule
""")
mk('VP','vp34','ovUnsizedBasedActualForm491',"""module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o, p; m #(.A('h5)) u(o); assign p = u.A; endmodule
""")
mk('VP','vp35','ovSizedActualMoreBases491',"""module s #(parameter logic [7:0] X = 1) (output logic [7:0] o); assign o = X + 1; endmodule
module m #(parameter A = 4'd15) (output logic [7:0] o); s #(.X(A)) c(o); endmodule
module top; logic [7:0] o; m #(.A(4'b1010)) u(o); endmodule
""")
mk('VP','vp36',U,"""module s #(parameter X = 1, parameter Z = X) (output logic [7:0] o); assign o = Z + 1; endmodule
module m #(parameter A = 4) (output logic [7:0] o); s #(.X(A)) c(o); endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
""")
mk('VP','vp37',U,"""module s #(parameter X = 1) (output logic [7:0] o); assign o = X + 1; endmodule
module m #(parameter A = 4, parameter Q = 2) (output logic [7:0] o); s #(.X(Q)) c(o); endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
""")
