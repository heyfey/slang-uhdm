module top(input c, input a, output logic y);
  logic clk;
  assign clk = c;
  default clocking @(posedge clk); endclocking
  always @(posedge clk) y <= a;
endmodule
