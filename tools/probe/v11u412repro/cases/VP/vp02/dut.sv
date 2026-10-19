// § propLocalVarListed412
module top(input logic clk, input int a, input logic b);
  property p2;
    int x, y;
    @(posedge clk) (b, x = a, y = a) |=> (x == y);
  endproperty
  assert property (p2);
endmodule
