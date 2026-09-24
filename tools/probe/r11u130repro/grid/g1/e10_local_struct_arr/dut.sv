// § defNetEndOnlyLoc130
module top;
  typedef struct packed { logic a; logic b; } S;
  S [3:0] x;
  assign x = '0;
endmodule
