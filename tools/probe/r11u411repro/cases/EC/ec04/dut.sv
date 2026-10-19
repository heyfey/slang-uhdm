// § pkgEnumCastTargetTs411
package p;
  typedef enum { A = 5, B = 7 } e_t;
  parameter e_t P = e_t'(7);
endpackage
module top (output [31:0] o);
  import p::*;
  assign o = P;
endmodule
