// § elabCloneInstTreeUnstored144
module m(input logic a, b, clk1);
  sequence s1(x, y); x ##1 y; endsequence
  a2: assert property (@(posedge clk1) s1(a, b));
endmodule
