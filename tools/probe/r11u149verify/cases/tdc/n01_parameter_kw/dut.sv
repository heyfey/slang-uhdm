// § pkgTypedefCastTargetTs140
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } cfg_t;
  parameter cfg_t C = cfg_t'(8'h5A);
endpackage
module dut(output logic [3:0] o);
  assign o = p::C.a;
endmodule
