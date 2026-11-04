// § clockingEventDefNet139
module top(input clk, input a, output logic y);
  clocking cb @(posedge clk); input a; endclocking
  always @(posedge clk) y <= a;
endmodule
