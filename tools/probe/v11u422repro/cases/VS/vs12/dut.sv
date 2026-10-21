// § strNetRefNotNetSkip422v
// a for loop variable of the strength net's name, then a whole read in an assign
module top(input d, g, output o);
  trireg (large) c;
  integer s;
  initial begin
    s = 0;
    for (int c = 0; c < 2; c++) s = s + c;
  end
  assign o = c;
  nmos n1 (c, d, g);
endmodule
