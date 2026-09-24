// § defNetEndOnlyLoc130
module top;
  typedef logic [2:0] b_t;
  enum b_t {A, B, C} x;
  initial x = C;
endmodule
