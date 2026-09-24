module m(input logic clk, rst, a, b);
  property p1;
    @(posedge clk) disable iff (rst) (a ##1 b) within (b ##2 a);
  endproperty
  a1: assert property (p1);
endmodule
