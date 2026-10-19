// § sequenceDeclListed406
module top(input logic clk, input logic a, input logic b);
  if (1) begin : g
    sequence s;
      a ##1 b;
    endsequence
    assert property (@(posedge clk) s);
  end
endmodule
