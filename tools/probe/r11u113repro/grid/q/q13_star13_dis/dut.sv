module m(input logic clk, rst, a, b, c);
  property p1;
    @(posedge clk) disable iff (rst) a |-> b[*1:3];
  endproperty
  a1: assert property (p1);
endmodule
