module m(input logic clk, rst, a, b, c);
  property p1;
    @(negedge clk) disable iff (!rst) a |=> b;
  endproperty
  property p2(s);
    disable iff (rst) s |-> ##[1:2] c;
  endproperty
  a1: assert property (p1);
  a2: assert property (@(posedge clk) p2(a));
endmodule
