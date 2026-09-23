module m(input logic clk, rst, a, b);
  property p1;
    @(posedge clk) disable iff (rst) a[*0:2] ##1 b |-> a;
  endproperty
  a1: assert property (p1);
endmodule
