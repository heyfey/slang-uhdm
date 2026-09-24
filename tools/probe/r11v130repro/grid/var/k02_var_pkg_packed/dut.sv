// § defNetVarNoSlot130v
package pkg;
  typedef struct packed { logic a; logic b; } S;
endpackage
module top;
  var pkg::S [1:0] x;
  assign x = '0;
endmodule
