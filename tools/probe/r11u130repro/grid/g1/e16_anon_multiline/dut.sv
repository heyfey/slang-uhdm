// § defNetEndOnlyLoc130
module top;
  enum logic [1:0] {
    A,
    B
  } x;
  enum {
    C,
    D
  } y;
  initial begin x = B; y = D; end
endmodule
