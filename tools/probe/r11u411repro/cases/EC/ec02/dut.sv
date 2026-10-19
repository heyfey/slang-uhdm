// § pkgEnumCastTargetTs411
package p;
  typedef enum { A, B, C } e_t;
  parameter e_t P = e_t'(2);
endpackage
module top (output [31:0] o);
  assign o = p::P;
endmodule
