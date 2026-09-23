module m(input logic clk, rst, a, b);
  property p1;
    a |=> b;
  endproperty
  a1: assert property (@(posedge clk) p1);
endmodule
