// § pkgTypedefCastTargetTs140
package q;
  typedef struct packed { logic [7:0] a; logic b; } cfg_t;
endpackage
package p;
  localparam q::cfg_t C = q::cfg_t'(0);
endpackage
module top(output logic o);
  assign o = p::C.b;
endmodule
