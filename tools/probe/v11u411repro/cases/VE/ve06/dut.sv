// § pkgAliasCastTargetTs411
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  typedef s_t t_t;
  parameter t_t P = t_t'(8'h12);
endpackage
module top (output [7:0] o);
  assign o = p::P;
endmodule
