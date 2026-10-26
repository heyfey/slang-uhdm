// § defOnlyNetLaterDeclNoType440v
module m (input clk);
  typedef logic [3:0] t;
  wire t a, b, c;
  tri t d, e;
endmodule
module top; endmodule
