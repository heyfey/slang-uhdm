module top(input c, input a, output logic y);
  wire clk = c;
  default clocking @(posedge clk); endclocking
  always @(posedge clk) y <= a;
endmodule
