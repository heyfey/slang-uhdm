// § parenCastReadsCastSyntax288 — parenthesized real conversions: real, shortreal and int from a real
module top(input int i, output real r, output shortreal s, output int k);
  real rv;
  always_comb begin
    rv = 2.5;
    r = (real'(i)) * 1.5;
    s = (shortreal'(i));
    k = (int'(rv)) + (int'(2.7));
  end
endmodule
