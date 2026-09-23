module m(input logic clk, rst, s, a, b);
  property p1;
    @(posedge clk) disable iff (rst) if (s) a |-> b else b;
  endproperty
  a1: assert property (p1);
endmodule
