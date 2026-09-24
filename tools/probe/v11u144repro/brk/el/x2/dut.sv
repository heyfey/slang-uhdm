// § elabCloneInstTreeUnstored144
module m(input logic clk, a, b);
  sequence s1(x, y); x ##1 y; endsequence
  property p1(x, y); @(posedge clk) s1(x, y) |-> x; endproperty
  for (genvar i = 0; i < 2; i++) begin : g
    c1: cover property (p1(a, b));
  end
  a2: assert property (@(posedge clk) s1(b, a));
endmodule
