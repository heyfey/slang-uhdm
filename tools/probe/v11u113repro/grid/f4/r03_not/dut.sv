module m(input logic clk, rst, a, b, c);
  property p1;
    @(posedge clk) not (a ##1 b[*1:2]);
  endproperty
  a1: assert property (p1);
endmodule
