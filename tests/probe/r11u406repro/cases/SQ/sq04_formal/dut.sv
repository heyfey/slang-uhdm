// § sequenceDeclListed406
module top;
  logic clk, a, b;
  sequence s2(x, y);
    x ##2 y;
  endsequence
  assert property (@(posedge clk) s2(a, b));
endmodule
