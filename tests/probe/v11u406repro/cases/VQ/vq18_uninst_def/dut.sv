// § sequenceDeclListed406
module chk(input logic clk, input logic a, input logic b, input logic c);
  sequence s;
    a ##1 b ##1 c;
  endsequence
  assert property (@(posedge clk) s);
endmodule
module top(input logic clk);
  if (0) begin : never
    chk u(clk, clk, clk, clk);
  end
endmodule
