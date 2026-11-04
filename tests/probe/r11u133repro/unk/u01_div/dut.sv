// § unknownParamOperandFile133
module top(output int o);
   parameter P = 'x;
   parameter Q = 'x;
   localparam int C = P / Q;
   assign o = int'(C);
endmodule
