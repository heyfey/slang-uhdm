// § dpConstUintForm489
module m #(parameter A = 4'd4) (output logic [7:0] o);
assign o = A;
endmodule
module top; logic [7:0] o;
m #(.A(4'd5)) u(o); defparam u.A = 6;
endmodule
