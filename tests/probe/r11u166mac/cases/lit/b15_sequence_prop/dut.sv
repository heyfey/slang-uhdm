// § ppBasedLitWsAfter166
module top(input clk, input [3:0] a, input b);
  property p1; @(posedge clk) (a == 4'h 2) |-> b; endproperty
  cp: cover property (p1);
  ap: assert property (@(posedge clk) (a != 4'h 0) |-> ##1 b);
endmodule
