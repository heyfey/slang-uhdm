// § propLocalVarListed412
module top(input logic clk, input int a, input logic b);
  property p5;
    integer x;
    shortint s;
    longint l;
    @(posedge clk) (b, x = a, s = 1, l = 2) |=> (x == a);
  endproperty
  cover property (p5);
endmodule
