module m(input logic clk, rst, a, b, c);
  property p1;
    @(posedge clk) disable iff (rst) a[*2] |-> b[->1] ##1 c[=2];
  endproperty
  property p2;
    @(posedge clk) disable iff (rst) a |-> b[*1:3];
  endproperty
  a1: assert property (p1);
  a2: assume property (p2);
endmodule
