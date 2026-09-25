// § ppBasedLitWsAfter166
module top(input clk, input [3:0] a);
  always @(posedge clk) assert (a != 4'b 0000) else $error("zero");
endmodule
