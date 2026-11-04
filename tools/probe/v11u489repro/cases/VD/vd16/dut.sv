// § dpConstUintForm489
module m #(parameter A = 'd4) (output logic [7:0] o);
assign o = A;
endmodule
module top; logic [7:0] o;
m u(o); defparam u.A = 6;
endmodule
