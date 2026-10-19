// § pkgEnumCastTargetTs411
package p;
  typedef enum logic [1:0] { A, B, C } e_t;
  localparam e_t P = e_t'(2);
endpackage
module top (output [1:0] o);
  assign o = p::P;
endmodule
