// § unknownParamOperandFile133
module top(output int o);
   localparam P = 'z;
   parameter int Q = 3;
   localparam int C = P * Q + P;
   assign o = int'(C);
endmodule
