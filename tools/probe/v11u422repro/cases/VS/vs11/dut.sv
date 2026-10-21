// § strNetRefNotNetSkip422v
// a strength vector net read through a part-select in an assign and a bit in a gate
module top(input d, g, output [1:0] o);
  trireg (medium) [3:0] c;
  assign o = c[1:0];
  nmos n1 (c[2], d, g);
endmodule
