// § defOnlyNetLaterDeclNoType440v
module m (input clk);
  typedef logic [3:0] t;
  t z1, z2;
  wire t w1 = 4'h3, w2;
  t q = 4'h1;
endmodule
module top; endmodule
