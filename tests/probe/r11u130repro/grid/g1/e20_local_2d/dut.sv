// § defNetEndOnlyLoc130
module top;
  typedef struct packed { logic a; logic b; } S;
  typedef enum logic [1:0] {X, Y} E;
  S [3:0][1:0] x;
  E [2:0] y;
  assign x = '0;
  initial y = '{3{X}};
endmodule
