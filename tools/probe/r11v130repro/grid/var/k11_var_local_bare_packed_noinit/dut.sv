// § defNetVarNoSlot130v
module top;
  typedef enum logic [1:0] {X, Y} E;
  typedef struct packed { logic a; logic b; } S;
  var E [2:0] y;
  var S [1:0] z;
endmodule
