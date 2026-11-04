// § defNetEndOnlyLoc130
module top;
  typedef enum logic [1:0] {X, Y} E;
  E
    [2:0]
    y;
  initial y = '{3{X}};
endmodule
