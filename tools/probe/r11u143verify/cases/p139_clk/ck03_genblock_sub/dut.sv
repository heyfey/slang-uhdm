// § clockingEventDefNet139
// case ck03: a default clocking inside a sub-module instantiated in a generate block
module sub(input logic clk, input logic a, output logic y);
  default clocking @(negedge clk); endclocking
  always @(negedge clk) y <= a;
endmodule
module top(input logic clk, input logic a, output logic y);
  if (1) begin : g
    sub u(.clk(clk), .a(a), .y(y));
  end
endmodule
