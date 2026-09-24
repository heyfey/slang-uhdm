// § unknownParamOperandFile133
// case uk01: an X parameter under a modulo operation of an int localparam
module top(output int o);
   parameter P = 'x;
   parameter Q = 5;
   localparam int C = P % Q;
   assign o = C;
endmodule
