// § dpConstUintForm489
module n #(parameter A = 4'd4) (output logic [7:0] o); assign o = A; endmodule
module m(output logic [7:0] o); n v(o); endmodule
module top; logic [7:0] o; m u(o); defparam u.v.A = 6; endmodule
