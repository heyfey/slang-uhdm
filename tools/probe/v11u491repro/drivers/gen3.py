import os
R='/tmp/wt_v11u491/tools/probe/v11u491repro/cases'
def mk(g,n,law,src):
    d=os.path.join(R,g,n); os.makedirs(d,exist_ok=True)
    open(os.path.join(d,'dut.sv'),'w').write('// § %s\n%s'%(law,src.lstrip('\n')))
S_ = "module s #(parameter X = 1) (output logic [7:0] o); assign o = X; endmodule\n"
U='ovUnsizedBasedActualForm491'
i=0
for pd,act in [("parameter A = 4","'b101"),("parameter A = 4","'o5"),("parameter A = 4","'d5"),("parameter logic [7:0] A = 4","'h5"),
               ("parameter int A = 4","'h5"),("parameter A = 4'd3","'h5"),("parameter A = 4","'hAb")]:
    i+=1
    mk('VP','vp%02d'%i,U,S_+f"""module m #({pd}) (output logic [7:0] o); s #(.X(A)) c(o); endmodule
module top; logic [7:0] o; m #(.A({act})) u(o); endmodule
""")
i+=1; mk('VP','vp%02d'%i,U,S_+"""module m #(parameter A = 4) (output logic [7:0] o); s #(A) c(o); endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
""")
i+=1; mk('VP','vp%02d'%i,U,"""module s #(parameter logic [7:0] X = 1) (output logic [7:0] o); assign o = X; endmodule
module m #(parameter A = 4) (output logic [7:0] o); s #(.X(A)) c(o); endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
""")
i+=1; mk('VP','vp%02d'%i,U,S_+"""module m #(parameter A = 4) (output logic [7:0] o); s #(.X(A + 1)) c(o); endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
""")
i+=1; mk('VP','vp%02d'%i,U,S_+"""module m #(parameter A = 4) (output logic [7:0] o); localparam B = A; s #(.X(B)) c(o); endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
""")
i+=1; mk('VP','vp%02d'%i,U,S_+"""module m #(parameter A = 4) (output logic [7:0] o); if (1) begin : g s #(.X(A)) c(o); end endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
""")
i+=1; mk('VP','vp%02d'%i,U,S_+"""module m #(parameter A = 4) (output logic [7:0] o); s c(o); defparam c.X = A; endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
""")
i+=1; mk('VP','vp%02d'%i,U,"""interface ifc #(parameter X = 1); logic [7:0] o; assign o = X; endinterface
module m #(parameter A = 4) (output logic [7:0] o); ifc #(.X(A)) c(); assign o = c.o; endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
""")
S='ovSizedActualMoreBases491'
for act in ["4'sb1010","4'o7","4'sd3","4'sh3","4'H3"]:
    i+=1
    mk('VP','vp%02d'%i,S,S_+f"""module m #(parameter A = 4'd15) (output logic [7:0] o); s #(.X(A)) c(o); endmodule
module top; logic [7:0] o; m #(.A({act})) u(o); endmodule
""")
T='bitNegTypedOperandSize491'
i+=1; mk('VP','vp%02d'%i,T,S_+"""module m #(parameter bit [7:0] A = 4'd4) (output logic [7:0] o); localparam B = ~A; s #(.X(B)) c(o); endmodule
module top; logic [7:0] o; m u(o); endmodule
""")
i+=1; mk('VP','vp%02d'%i,'bitNegBareNameActual491',S_+"""module m #(parameter A = 4) (output logic [7:0] o); localparam B = ~A; s #(.X(B)) c(o); endmodule
module top; localparam P = 5; logic [7:0] o; m #(.A(P)) u(o); endmodule
""")
i+=1; mk('VP','vp%02d'%i,'bitNegUnsizedBasedActual491',S_+"""module m #(parameter A = 4) (output logic [7:0] o); localparam B = ~A; s #(.X(B)) c(o); endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
""")
i+=1; mk('VP','vp%02d'%i,'unboundedDepBesideDefparam491',S_+"""module m #(parameter A = 4'd15, parameter Y = 1) (output logic [7:0] o); localparam B = A + 4'd1; s #(.X(B)) c(o); endmodule
module top; logic [7:0] o; m u(o); defparam u.Y = 2; endmodule
""")
i+=1; mk('VP','vp%02d'%i,'unboundedSubSize64_491',S_+"""module m #(parameter A = 4'd3) (output logic [7:0] o); localparam B = A - 4'd1; s #(.X(B)) c(o); endmodule
module top; logic [7:0] o; m u(o); endmodule
""")
i+=1; mk('VP','vp%02d'%i,'unboundedSubSize64_491',S_+"""module m #(parameter A = 4'd3) (output logic [7:0] o); localparam B = A - 4'd1; s #(.X(B + 1)) c(o); endmodule
module top; logic [7:0] o; m u(o); endmodule
""")
