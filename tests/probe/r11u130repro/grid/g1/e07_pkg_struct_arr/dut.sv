// § defNetEndOnlyLoc130
package pkg;
  parameter int N = 4;
  typedef struct packed { logic a; logic b; } S;
endpackage
module top;
  pkg::S [pkg::N-1:0] x;
  assign x = '0;
endmodule
