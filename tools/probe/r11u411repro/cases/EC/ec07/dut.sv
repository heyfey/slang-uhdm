// § pkgEnumCastTargetTs411
package p;
  typedef enum { A, B, C } e_t;
  parameter int W = 2;
  parameter e_t P = e_t'(W);
endpackage
module top (output [31:0] o);
  import p::*;
  assign o = P;
endmodule
