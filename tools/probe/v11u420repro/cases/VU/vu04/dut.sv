// § unitVarNetSourceOrder420
int cnt = 0;
module top(input logic clk, a);
  assign w = a;
  always @(posedge clk) if (cnt > 0) $display("x");
  property p; int l; @(posedge clk) (a, l = 1) |-> l == 1; endproperty
  assert property (p);
endmodule
