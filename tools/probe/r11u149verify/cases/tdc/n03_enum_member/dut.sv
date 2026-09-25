// § pkgTypedefCastTargetTs140
package p;
  typedef enum logic [1:0] { R, G, B } col_t;
  typedef struct packed { col_t c; logic [5:0] v; } cfg_t;
  localparam cfg_t C = cfg_t'(0);
endpackage
module dut(output logic [5:0] o);
  assign o = p::C.v;
endmodule
