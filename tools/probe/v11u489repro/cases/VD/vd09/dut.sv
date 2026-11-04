// § dpConstUintForm489
module m #(parameter A = 4'd4) (output logic [7:0] o);
assign o = A;
endmodule
module top; logic [7:0] o;
logic [7:0] o2; m u1(o); m u2(o2); defparam u1.A = 6;
endmodule
