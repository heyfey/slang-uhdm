// § paramValueIsDefRhs124
module m #(parameter type T = logic [3:0], parameter int W = $bits(T)) (output logic [W-1:0] o); assign o = '1; endmodule
module top(output logic [7:0] o); m #(.T(logic [7:0])) u(.o(o)); endmodule
