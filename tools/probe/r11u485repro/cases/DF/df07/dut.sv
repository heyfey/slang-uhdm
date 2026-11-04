// § ovDefparamWinsValue485
module m #(parameter int A = 4, parameter B = 1) (output logic [7:0] o); assign o = A + B; endmodule
module top; logic [7:0] o; m #(.A(5), .B(2)) u(o); defparam u.A = 9; endmodule
