// § strNetRefNotNetSkip422v
// a strength net referenced through a hierarchical name in the same module
module top(input d, g, output o);
  trireg (large) c;
  assign o = top.c;
  nmos n1 (c, d, g);
endmodule
