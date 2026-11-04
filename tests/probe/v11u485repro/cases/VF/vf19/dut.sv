// § ovDefparamWinsValue485
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module mid (output logic [7:0] o); m #(.A(5)) u(o); endmodule
module top; logic [7:0] o1, o2; mid x(o1); mid y(o2); defparam x.u.A = 6; endmodule
