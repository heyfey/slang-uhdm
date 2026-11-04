// § sequenceDeclListed406
module top;
  logic clk, a, b, c;
  sequence sa;
    @(posedge clk) a;
  endsequence
  sequence sb;
    @(negedge clk) b ##1 c;
  endsequence
  cover property (sa);
  assert property (sb);
endmodule
