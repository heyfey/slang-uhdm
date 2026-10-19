// § sequenceDeclListed406
module top(input logic clk, input logic a, input logic b);
  sequence s;
    a ##[2:4] b;
  endsequence
  assert property (@(posedge clk) s);
endmodule
