// § pkgTypedefCastTargetTs140
package p;
  typedef struct packed { logic [7:0] a; logic b; } cfg_t;
  typedef cfg_t cfg2_t;
  localparam cfg2_t C = cfg2_t'(0);
endpackage
module top(output logic o);
  assign o = p::C.b;
endmodule
