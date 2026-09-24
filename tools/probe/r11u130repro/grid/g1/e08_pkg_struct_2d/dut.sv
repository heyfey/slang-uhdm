// § defNetEndOnlyLoc130
package pkg;
  typedef struct packed { logic a; logic b; } S;
endpackage
module top;
  pkg::S [1:0][2:0] x;
  assign x = '0;
endmodule
