// § strNetRefNotNetSkip422v
// a strength vector net read through a bit-select in an assign, then a gate
module top(input d, g, output o);
  trireg (medium) [1:0] c;
  assign o = c[0];
  nmos n1 (c[1], d, g);
endmodule
