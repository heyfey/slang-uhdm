module m(input logic clk, rst, a, b);
  property p1;
    @(posedge clk) disable iff (rst) ##1 a |-> b;
  endproperty
  a1: assert property (p1);
endmodule
