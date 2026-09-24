// § clockingEventDefNet139
module top(input logic clk, input logic rst, input logic d, output logic q);
  default clocking cb @(negedge clk iff !rst); endclocking
  always_ff @(negedge clk) q <= d;
endmodule
