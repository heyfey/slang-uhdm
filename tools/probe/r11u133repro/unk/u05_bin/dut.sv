// § unknownParamOperandFile133
module top(output int o);
   parameter A = 4'b1x01;
   localparam logic [3:0] C = A & 4'hf;
   assign o = int'(C);
endmodule
