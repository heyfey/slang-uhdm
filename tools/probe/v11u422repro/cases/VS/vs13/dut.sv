// § strNetRefNotNetSkip422v
// a named block declaring the name, a later assign reading the net
module top(input d, g, output o, output reg p);
  trireg (large) c;
  initial begin : b
    logic c;
    c = 1'b0;
    p = c;
  end
  assign o = c;
endmodule
