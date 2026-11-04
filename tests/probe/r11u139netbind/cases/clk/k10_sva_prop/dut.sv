// § clockingEventDefNet139
module top(input clk, input a, input b);
  default clocking @(posedge clk); endclocking
  assert property (a |-> b);
endmodule
