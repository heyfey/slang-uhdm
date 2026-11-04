// § dpConstUintForm489
module m #(parameter A = 4'd4) (output logic [7:0] o);
assign o = A;
endmodule
module top; logic [7:0] o;
m u(o); defparam u.A = 300;
endmodule
