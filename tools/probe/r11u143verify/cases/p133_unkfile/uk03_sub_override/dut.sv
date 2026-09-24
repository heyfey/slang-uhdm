// § unknownParamOperandFile133
// case uk03: the X operand arrives as an instance override
module sub #(parameter P = 1, parameter Q = 2) (output int o);
   localparam int C = P + Q;
   assign o = C;
endmodule
module top(output int o); sub #(.P('x)) u(.o(o)); endmodule
