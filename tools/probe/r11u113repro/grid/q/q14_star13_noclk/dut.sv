module m(input logic clk, rst, a, b, c);
  property p1;
    a |-> b[*1:3];
  endproperty
  a1: assert property (@(posedge clk) p1);
endmodule
