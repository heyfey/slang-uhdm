module m(input logic clk, rst, a, b, c);
  property p1(x, y);
    @(posedge clk) x |-> y[*1:3];
  endproperty
  a1: assert property (p1(a, b));
endmodule
