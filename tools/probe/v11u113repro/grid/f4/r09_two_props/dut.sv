module m(input logic clk, rst, a, b, c);
  property p1;
    @(posedge clk) a |-> b[*1:3];
  endproperty
  property p2;
    @(posedge clk) c |-> b[*2:4];
  endproperty
  a1: assert property (p1);
  a2: cover property (p2);
endmodule
