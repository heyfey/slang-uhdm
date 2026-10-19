// § pkgEnumCastTargetTs411
package p;
  typedef enum { A, B, C } e_t;
  parameter e_t P = e_t'(1);
  parameter e_t Q = B;
endpackage
module top (output [31:0] o);
  import p::*;
  assign o = P + Q;
endmodule
