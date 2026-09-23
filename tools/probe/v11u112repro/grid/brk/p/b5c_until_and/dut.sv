module m(input logic clk, rst, a, b, c, d);
  property p1;
    @(posedge clk) disable iff (rst) (a until b) and (c |-> d);
  endproperty
  property p2;
    @(posedge clk) disable iff (rst) a s_until_with b;
  endproperty
  a1: assert property (p1);
  a2: cover property (p2);
endmodule
