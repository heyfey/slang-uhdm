// § dpConstUintForm489
module m #(parameter A = 4'd4) (output logic [7:0] o);
logic [7:0] q; always_comb q = A; sub s(.x(o), .i(A));
endmodule
module top; logic [7:0] o;
m u(o); defparam u.A = 6;
endmodule
module sub(output logic [7:0] x, input logic [7:0] i); assign x = i; endmodule
