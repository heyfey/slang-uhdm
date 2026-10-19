// § sequenceDeclListed406
module top(input logic clk, input logic rst, input logic a, input logic b);
  sequence s;
    a ##2 b;
  endsequence
  assert property (@(posedge clk) disable iff (rst) s);
  assert property (@(posedge clk) a |-> s);
endmodule
