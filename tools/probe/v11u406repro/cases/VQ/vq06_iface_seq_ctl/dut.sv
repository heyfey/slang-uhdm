// § sequenceDeclListed406
interface bus(input logic clk);
  logic a, b;
  sequence s;
    a ##1 b;
  endsequence
  assert property (@(posedge clk) s);
endinterface
module top(input logic clk);
  bus b0(clk);
endmodule
