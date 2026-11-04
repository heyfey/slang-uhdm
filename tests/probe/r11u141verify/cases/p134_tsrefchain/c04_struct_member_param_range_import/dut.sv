// § pkgTsRefObjChainName134
// case c04: a package parameter typed by a package struct whose member range reads a package parameter, imported
package p;
  parameter int W = 3;
  typedef struct packed { logic [W-1:0] a; logic [W-1:0] b; } s_t;
  parameter s_t INIT = '{a: 3'd1, b: 3'd2};
endpackage
module top(output logic [5:0] o);
  import p::*;
  assign o = INIT;
endmodule
