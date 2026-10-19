// § pkgAliasCastTargetTs411
package p;
  typedef logic [3:0] v_t;
  parameter v_t V = v_t'(5);
endpackage
module top (output [3:0] o);
  assign o = p::V;
endmodule
