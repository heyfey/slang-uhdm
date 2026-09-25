// § pkgTypedefCastTargetTs140
package p;
  localparam int A = 3;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } cfg_t;
  localparam cfg_t C = cfg_t'(A + 1);
endpackage
module dut(output logic [3:0] o);
  assign o = p::C.b;
endmodule
