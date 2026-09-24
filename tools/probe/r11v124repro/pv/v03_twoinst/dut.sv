// § paramValueIsDefRhs124
module m #(parameter W = 4) (output logic [W-1:0] o); assign o = W; endmodule
module top(output logic [3:0] a, output logic [7:0] b); m u1(.o(a)); m #(8) u2(.o(b)); endmodule
