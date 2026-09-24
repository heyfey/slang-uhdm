// § paramValueIsDefRhs124
module m #(parameter string S = "ab") (output logic [7:0] o); assign o = S[0]; endmodule
module top(output logic [7:0] o); m #(.S("xyz")) u(.o(o)); endmodule
