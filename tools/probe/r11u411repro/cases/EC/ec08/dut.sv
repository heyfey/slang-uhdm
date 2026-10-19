// § pkgAliasCastTargetTs411
package p;
  typedef enum { A, B, C } e_t;
  typedef logic [3:0] v_t;
  parameter v_t V = v_t'(5);
  parameter e_t P = e_t'(0);
endpackage
module top (output [31:0] o);
  import p::*;
  assign o = P + V;
endmodule
