// § seqMatchItemsDropped404
module top;
  logic clk, a, b;
  int x;
  sequence s1;
    int v;
    (a, v = x) ##1 (b && v > 0);
  endsequence
  assert property (@(posedge clk) s1);
endmodule
