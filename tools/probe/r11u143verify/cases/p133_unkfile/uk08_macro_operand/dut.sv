// § unknownParamOperandFile133
// case uk08: the X operand is written through a macro
`define PX P
module top(output int o);
   parameter P = 'x;
   parameter Q = 3;
   localparam int C = `PX / Q;
   assign o = C;
endmodule
