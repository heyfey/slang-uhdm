// § bitNegBareNameActual491
module s #(parameter X = 1) (output logic [7:0] o); assign o = X; endmodule
module m #(parameter A = 4) (output logic [7:0] o); localparam B = ~A; s #(.X(B)) c(o); endmodule
module top; localparam P = 5; logic [7:0] o; m #(.A(P)) u(o); endmodule
