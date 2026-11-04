// § dpConstUintForm489
module m #(parameter A = 8'hFF) (output logic [7:0] o);
assign o = A;
endmodule
module top; logic [7:0] o;
m u(o); defparam u.A = 3;
endmodule
