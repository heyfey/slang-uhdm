// § ovDefparamWinsValue485
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o; m u(o); defparam u.A = 06; endmodule
