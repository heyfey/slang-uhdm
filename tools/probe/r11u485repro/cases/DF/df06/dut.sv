// § ovDefparamWinsValue485
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module mid (output logic [7:0] o); m #(.A(5)) u(o); endmodule
module top; logic [7:0] o; mid x(o); defparam x.u.A = 7; endmodule
