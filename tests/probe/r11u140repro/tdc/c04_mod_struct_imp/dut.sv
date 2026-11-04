// § pkgTypedefCastTargetTs140
package p;
  typedef struct packed { logic [7:0] a; logic b; } cfg_t;
endpackage
module top(output logic o);
  import p::*;
  localparam cfg_t C = cfg_t'(0);
  assign o = C.b;
endmodule
