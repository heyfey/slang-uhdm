// § paramValueIsDefRhs124
module m #(parameter real R = 1.5, parameter int I = 2) (output int o); assign o = int'(R) + I; endmodule
module top(output int o); m #(.R(2.75), .I(9)) u(.o(o)); endmodule
