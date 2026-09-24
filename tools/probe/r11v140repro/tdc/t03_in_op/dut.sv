// § pkgTypedefCastTargetTs140
package p;
  typedef struct packed { logic [7:0] a; logic b; } cfg_t;
  localparam cfg_t C = cfg_t'(1) | cfg_t'(2);
endpackage
module top(output logic o);
  assign o = p::C.b;
endmodule
