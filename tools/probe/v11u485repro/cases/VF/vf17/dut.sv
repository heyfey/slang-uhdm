// § ovDefparamWinsValue485
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o; m #(.A(5)) u(o); defparam u.A = 'h6; endmodule
