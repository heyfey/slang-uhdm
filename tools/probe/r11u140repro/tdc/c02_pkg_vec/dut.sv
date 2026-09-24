// § pkgTypedefCastTargetTs140
package p;
  typedef logic [7:0] w_t;
  localparam w_t W = w_t'(5);
endpackage
module top(output logic [7:0] o);
  assign o = p::W;
endmodule
