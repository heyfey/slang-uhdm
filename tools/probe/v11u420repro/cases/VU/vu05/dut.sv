// § unitVarNetSourceOrder420
int cnt = 0;
int dd = 0;
module top(input logic clk, a);
  property p; int l; @(posedge clk) (a, l = 1) |-> l == 1; endproperty
  assert property (p);
  always @(posedge clk) if (dd > 0) $display("y");
  always @(posedge clk) if (cnt > 0) $display("x");
endmodule
