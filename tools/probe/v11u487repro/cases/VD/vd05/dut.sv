// § dpDepPreDefparamValue487
module m #(parameter A = 4, parameter B = A + 1) (output logic [7:0] o); assign o = B; endmodule
module top; logic [7:0] o; m u(o); defparam u.A = 6; endmodule
