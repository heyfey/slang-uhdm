module m(input logic clk, rst, a, b);
  property p1;
    @(posedge clk) disable iff (rst) first_match(a ##1 b) |-> a;
  endproperty
  a1: assert property (p1);
endmodule
