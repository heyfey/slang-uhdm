// § unknownParamOperandFile133
// case uk05: an X parameter under a unary minus
module top(output int o);
   parameter P = 'x;
   localparam int C = -P;
   assign o = C;
endmodule
