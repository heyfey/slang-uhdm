module m(input logic clk, rst, a, b);
  property p1;
    @(posedge clk) disable iff (rst) a ##1 b;
  endproperty
  c1: cover property (p1);
endmodule
