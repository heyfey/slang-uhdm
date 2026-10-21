// § strNetRefNotNetSkip422v
// a named block's own variable shadows the strength net's name
module top(input d, g, output reg o);
  trireg (large) c;
  always @(d) begin : b
    reg c;
    c = d;
    o = c;
  end
  nmos n1 (c, d, g);
endmodule
