// § defNetVarNoSlot130v
module top;
  typedef enum logic [1:0] {X, Y} E;
  var E [2:0] y;
  initial y = '{3{X}};
endmodule
