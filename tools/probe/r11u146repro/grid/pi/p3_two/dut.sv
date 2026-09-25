// § portInitAssignAtHeader146
module dut(clk, a_old, b);
  input wire clk;
  output reg a_old = 0;
  output reg b = 1;
  always @(posedge clk) a_old <= b;
endmodule
