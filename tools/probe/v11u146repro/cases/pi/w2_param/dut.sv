// § portInitAssignAtHeader146
module dut(clk, q);
  parameter P = 3;
  input clk;
  output reg [3:0] q = P;
  always @(posedge clk) q <= q + 1;
endmodule
