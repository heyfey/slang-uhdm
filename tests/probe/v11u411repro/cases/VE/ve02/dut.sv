// § pkgEnumCastTargetTs411
package p;
  typedef enum { A, B, C } e_t;
  parameter int P = int'(e_t'(1)) + 1;
endpackage
module top (output [31:0] o);
  import p::*;
  assign o = P;
endmodule
