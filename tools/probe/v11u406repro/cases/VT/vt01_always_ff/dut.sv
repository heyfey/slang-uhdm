// § timeModVarIsNet406
module top(input logic clk);
  time t;
  always @(posedge clk) t <= $time;
endmodule
