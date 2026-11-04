// § ovDefparamWinsValue485
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module mid #(parameter X = 3) (output logic [7:0] o); m #(.A(X)) u(o); endmodule
module top; logic [7:0] o; mid x(o); defparam top.x.u.A = 6; endmodule
