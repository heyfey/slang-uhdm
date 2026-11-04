// § strNetRefNotNetSkip422v
// a strength vector net read first through a bit-select, then whole
module top(input d, g, output o, output [1:0] p);
  trireg (medium) [1:0] c;
  assign o = c[0];
  assign p = c;
  nmos n1 (c, d, g);
endmodule
