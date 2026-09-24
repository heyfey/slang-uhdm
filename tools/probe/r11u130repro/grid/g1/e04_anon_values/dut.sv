// § defNetEndOnlyLoc130
module top;
  enum logic [1:0] {A = 2'd1, B = 2'd2} x;
  enum {C = 3, D} y;
  initial begin x = B; y = D; end
endmodule
