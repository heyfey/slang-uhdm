module m(input logic clk, rst, a, b);
  property p1;
    @(posedge clk) a |-> b;
  endproperty
  a1: assert property (p1);
endmodule
