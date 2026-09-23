module m(input logic clk, rst, a, b, c);
  default clocking cb @(posedge clk); endclocking
  property p1;
    disable iff (rst) a ##1 b |-> c;
  endproperty
  a1: assert property (p1);
endmodule
