// § unknownParamOperandFile133
module sub #(parameter A = 'x) (output int o);
   localparam int C = A - 1;
   assign o = int'(C);
endmodule
module top(output int o);
   sub u(.o(o));
endmodule
