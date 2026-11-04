// § ovDefparamWinsValue485
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o, o2; m #(.A(5)) u(o); m #(.A(5)) v(o2); defparam u.A = 6; endmodule
