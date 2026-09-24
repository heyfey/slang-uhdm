// § clockingEventDefNet139
// case ck01: a default clocking block on an edge event
module top(input logic clk, input logic a, output logic y);
  default clocking cb @(edge clk); endclocking
  always @(posedge clk) y <= a;
endmodule
