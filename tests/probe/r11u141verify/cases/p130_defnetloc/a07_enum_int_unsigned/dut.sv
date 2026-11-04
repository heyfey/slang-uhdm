// § defNetEndOnlyLoc130
// case a07: anonymous enum with an `int unsigned` base and explicit values
module top(output logic [31:0] o);
  enum int unsigned {A = 1, B = 5, C = 9} x;
  assign o = x;
endmodule
