// § defNetEndOnlyLoc130
module top;
  typedef struct packed { logic a; logic b; } S;
  wire S [1:0][2:0] x;
  S [3:0][1:0] y;
  assign x = '0;
  assign y = '0;
endmodule
