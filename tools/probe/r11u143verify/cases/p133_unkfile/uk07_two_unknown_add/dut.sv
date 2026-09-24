// § unknownParamOperandFile133
// case uk07: two X operands under an addition, typed int
module top(output int o);
   parameter P = 'x;
   parameter Q = 'z;
   localparam int C = P + Q;
   assign o = C;
endmodule
