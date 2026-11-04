// § emptyConcatArrayVar413
module top;
  int q[$];
  logic clk;
  always @(posedge clk) q <= {};
endmodule
