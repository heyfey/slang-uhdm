// § pkgAliasCastTargetTs411
package p;
  typedef int i_t;
  parameter i_t P = i_t'(3);
endpackage
module top (output [31:0] o);
  import p::*;
  assign o = P;
endmodule
