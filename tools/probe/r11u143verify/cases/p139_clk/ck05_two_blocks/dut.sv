// § clockingEventDefNet139
// case ck05: a default clocking and a named clocking on different clocks
module top(input logic c1, input logic c2, input logic a, output logic y);
  default clocking d1 @(posedge c1); endclocking
  clocking n2 @(negedge c2); input a; endclocking
  always @(posedge c1) y <= a;
endmodule
