module m(input logic clk, rst, a, b);
  property p1(x, y, r);
    @(posedge clk) disable iff (r) x |-> y;
  endproperty
  a1: assert property (p1(a, b, rst));
endmodule
