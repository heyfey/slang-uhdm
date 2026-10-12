// § caStructSetterCastMemberWidthNoFold301
package cfg_pkg;
  typedef struct packed { int unsigned W; } sub_t;
  typedef struct packed { sub_t sub; int unsigned VLEN; } cfg_t;
  localparam cfg_t DefaultCfg = '{sub: '{W: 32'd8}, VLEN: 32'd8};
endpackage
module dut #(parameter cfg_pkg::cfg_t Cfg = cfg_pkg::DefaultCfg) (output logic [7:0] b_o);
  typedef struct packed { logic [7:0] x; logic [7:0] y; } it_t;
  localparam it_t I = '{x: Cfg.sub.W'(1), y: Cfg.sub.W'(2)};
  assign b_o = I.y;
endmodule
