// § defNetEndOnlyLoc130
package pkg;
  typedef struct packed { logic a; logic b; } S;
endpackage
module top;
  pkg::S [1:0] x, y;
  assign x = '0;
  assign y = x;
endmodule
