// § pkgTypedefCastTargetTs140
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  localparam e_t E = e_t'(1);
endpackage
module top(output logic [1:0] o);
  assign o = p::E;
endmodule
