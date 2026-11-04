// § implicitNetMintNoFile131
module top (input logic clk, input logic a, input logic b);
  sequence s1(x, y);
    x ##1 y;
  endsequence
  assert property (@(posedge clk) s1(a, b));
endmodule
