module top(input clk, input a, output logic y);
  global clocking gc @(posedge clk); endclocking
  always @(posedge clk) y <= a;
endmodule
