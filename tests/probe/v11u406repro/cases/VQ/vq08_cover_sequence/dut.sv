// § sequenceDeclListed406
module top(input logic clk, input logic a, input logic b);
  sequence s;
    a ##1 b;
  endsequence
  cover sequence (@(posedge clk) s);
endmodule
