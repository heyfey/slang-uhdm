// § realLitValueIsText124
module m #(parameter real R = 1.5) (output real o); assign o = R; endmodule
module top(output real o); m #(.R(2.75)) u(.o(o)); endmodule
