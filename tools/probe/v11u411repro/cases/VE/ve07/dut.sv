// § pkgAliasCastTargetTs411
package q;
  typedef int i_t;
endpackage
package p;
  parameter q::i_t P = q::i_t'(3);
endpackage
module top (output [31:0] o);
  assign o = p::P;
endmodule
