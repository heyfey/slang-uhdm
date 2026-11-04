// § ovDefparamWinsValue485
module m #(parameter A = 4, parameter C = 1) (output logic [7:0] o); assign o = A + C; endmodule
module top; logic [7:0] o; m #(5, 2) u(o); defparam u.C = 9; endmodule
