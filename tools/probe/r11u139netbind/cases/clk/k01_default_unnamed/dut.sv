module top(input clk, input a, output logic y);
  default clocking @(posedge clk); endclocking
  always @(posedge clk) y <= a;
endmodule
