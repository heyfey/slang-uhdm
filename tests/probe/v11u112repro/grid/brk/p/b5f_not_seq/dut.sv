module m(input logic clk, rst, a, b);
  property p1;
    @(posedge clk) disable iff (rst) not (a ##1 b);
  endproperty
  property p2(x, y);
    @(posedge clk) disable iff (rst) x |-> y;
  endproperty
  a1: assert property (p1);
  a2: assert property (p2(a, b));
  a3: assert property (p2(b, a));
endmodule
