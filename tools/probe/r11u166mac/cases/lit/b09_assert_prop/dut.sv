// § ppBasedLitWsAfter166
module top(input clk, input [7:0] a);
  chk: assert property (@(posedge clk) a == 8'h 3) else $error("x");
endmodule
