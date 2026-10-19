// § propLocalVarListed412
module top(input logic clk, input logic [3:0] a, input logic b);
  property p1;
    logic [3:0] x;
    @(posedge clk) (b, x = a) |=> (a == x);
  endproperty
  assert property (p1);
endmodule
