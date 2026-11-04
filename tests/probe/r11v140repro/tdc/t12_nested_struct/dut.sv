// § pkgTypedefCastTargetTs140
package p;
  typedef struct packed { logic [3:0] x; } in_t;
  typedef struct packed { in_t i; logic b; } cfg_t;
  localparam cfg_t C = cfg_t'(5'h1f);
endpackage
module top(output logic o);
  assign o = p::C.i.x[0];
endmodule
