// § unknownParamOperandFile133
// case uk04: an X parameter as the left operand of a shift
module top(output int o);
   parameter P = 'x;
   localparam int C = P << 2;
   assign o = C;
endmodule
