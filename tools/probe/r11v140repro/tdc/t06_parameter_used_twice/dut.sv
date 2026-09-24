// § pkgTypedefCastTargetTs140
package p;
  typedef struct packed { logic [7:0] a; logic b; } cfg_t;
  parameter cfg_t C = cfg_t'(9'h1ff);
  parameter cfg_t D = cfg_t'(C);
endpackage
module top(output logic o);
  assign o = p::D.b;
endmodule
