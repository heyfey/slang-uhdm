// § pkgTypedefCastTargetTs140
package p1;
  typedef struct packed { logic [3:0] a; } cfg_t;
  localparam cfg_t C = cfg_t'(3);
endpackage
package p2;
  typedef struct packed { logic [7:0] a; logic b; } cfg_t;
  localparam cfg_t C = cfg_t'(1);
endpackage
module top(output logic o);
  assign o = p1::C.a[0] ^ p2::C.b;
endmodule
