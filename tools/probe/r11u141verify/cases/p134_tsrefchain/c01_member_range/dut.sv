// § pkgTsRefObjChainName134
// case c01: a package struct typedef whose member range references a package parameter
package p;
  parameter int W = 5;
  typedef struct packed { logic [W-1:0] a; logic b; } s_t;
endpackage
module top(output logic [5:0] o);
  p::s_t v;
  assign v = '0;
  assign o = v;
endmodule
