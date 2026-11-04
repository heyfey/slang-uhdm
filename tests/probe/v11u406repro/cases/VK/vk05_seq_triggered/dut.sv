// § sequenceDeclListed406
module top(input logic clk, input logic a, input logic b, output logic o);
  sequence s;
    @(posedge clk) a ##1 b;
  endsequence
  always @(posedge clk) o <= s.triggered;
endmodule
