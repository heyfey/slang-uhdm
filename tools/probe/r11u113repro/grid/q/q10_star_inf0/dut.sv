module m(input logic clk, rst, a, b, c);
  property p1;
    @(posedge clk) a |-> b[*0:$];
  endproperty
  a1: assert property (p1);
endmodule
