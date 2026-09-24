// § defNetEndOnlyLoc130
package pkg;
  typedef struct packed { logic a; logic b; } S;
endpackage
module top;
  wire pkg::S [1:0][2:0] x;
  pkg::S [1:0][2:0] y;
  assign x = '0;
  assign y = x;
endmodule
