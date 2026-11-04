// § bitNegTypedOperandSize491
module s #(parameter X = 1) (output logic [7:0] o); assign o = X; endmodule
module m #(parameter bit [7:0] A = 4'd4) (output logic [7:0] o); localparam B = ~A; s #(.X(B)) c(o); endmodule
module top; logic [7:0] o; m u(o); endmodule
