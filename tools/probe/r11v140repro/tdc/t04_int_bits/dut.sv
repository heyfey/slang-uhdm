// § pkgTypedefCastTargetTs140
package p;
  typedef struct packed { logic [7:0] a; logic b; } cfg_t;
  localparam int W = $bits(cfg_t'(0));
endpackage
module top(output int o);
  assign o = p::W;
endmodule
