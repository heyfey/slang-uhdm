// § pkgTypedefCastTargetTs140
package p;
  typedef struct packed { logic [7:0] a; logic b; } cfg_t;
  localparam int K = 4;
  localparam cfg_t C = cfg_t'(K);
  localparam cfg_t E = cfg_t'('{a: 8'h3, b: 1'b1});
endpackage
module top(output logic o);
  assign o = p::C.b ^ p::E.b;
endmodule
