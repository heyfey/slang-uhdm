// § ovDefparamWinsValue485
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o1, o2; m #(.A(5)) u1(o1); m #(.A(5)) u2(o2); defparam u1.A = 6; defparam u2.A = 7; endmodule
