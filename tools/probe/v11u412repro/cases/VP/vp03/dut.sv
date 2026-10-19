// § propLocalVarListed412
module top(input logic clk, input byte a, input logic b);
  property p3(v);
    byte x;
    bit q;
    @(posedge clk) (v, x = a, q = 1'b1) |=> (q && x == a);
  endproperty
  assert property (p3(b));
endmodule
