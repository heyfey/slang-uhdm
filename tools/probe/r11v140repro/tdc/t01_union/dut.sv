// § pkgTypedefCastTargetTs140
package p;
  typedef union packed { logic [7:0] a; logic [7:0] b; } u_t;
  localparam u_t C = u_t'(0);
endpackage
module top(output logic [7:0] o);
  assign o = p::C.a;
endmodule
