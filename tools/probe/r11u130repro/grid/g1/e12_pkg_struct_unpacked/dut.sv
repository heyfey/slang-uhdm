// § defNetEndOnlyLoc130
package pkg;
  typedef struct packed { logic a; logic b; } S;
endpackage
module top;
  pkg::S x [2];
  pkg::S [1:0] y [3];
endmodule
