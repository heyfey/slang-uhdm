module m(input logic clk, rst, a, b, c);
  property p1;
    @(posedge clk) disable iff (rst) a |-> ##1 b ##2 c;
  endproperty
  property p2;
    disable iff (rst) @(posedge clk) a |=> b;
  endproperty
  a1: assert property (p1);
  a2: assert property (p2);
endmodule
