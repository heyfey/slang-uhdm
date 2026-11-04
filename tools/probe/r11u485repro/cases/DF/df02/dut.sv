// § ovDefparamWinsValue485
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o; m #(5) u(o); defparam u.A = 6; endmodule
