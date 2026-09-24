// § clockingEventDefNet139
// case ck06: a global clocking inside a sub-module
module sub(input logic clk, input logic a, output logic y);
  global clocking gc @(posedge clk); endclocking
  always @(posedge clk) y <= a;
endmodule
module top(input logic clk, input logic a, output logic y); sub u(.clk(clk), .a(a), .y(y)); endmodule
