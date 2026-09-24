module top(input clk, input rst, input a, output logic y);
  default clocking @(posedge clk or negedge rst); endclocking
  always @(posedge clk) y <= a;
endmodule
