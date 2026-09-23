module m(input logic clk, rst, a, b);
  sequence s1; a ##1 b; endsequence
  property p1;
    @(posedge clk) disable iff (rst) s1 |-> b;
  endproperty
  a1: assert property (p1);
endmodule
