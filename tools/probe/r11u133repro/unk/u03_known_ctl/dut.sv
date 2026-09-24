// § unknownParamOperandFile133
module top(output int o);
   parameter A = 4;
   localparam int C = A + 1;
   assign o = int'(C);
endmodule
