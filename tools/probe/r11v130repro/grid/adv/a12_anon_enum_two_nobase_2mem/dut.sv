// § defNetEndOnlyLoc130
module top;
  enum {A, B} x;
  enum integer {C, D, E} y;
  initial begin x = B; y = E; end
endmodule
