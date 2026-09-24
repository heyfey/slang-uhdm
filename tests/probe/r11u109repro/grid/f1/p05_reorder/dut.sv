package cfg_pkg;
  typedef struct packed { int unsigned XLEN; int unsigned VLEN; } cfg_t;
  localparam cfg_t DefaultCfg = '{XLEN: 32'd64, VLEN: 32'd64};
endpackage
module dut #(parameter cfg_pkg::cfg_t Cfg = cfg_pkg::DefaultCfg) (input logic a_i, output logic [Cfg.XLEN-1:0] b_o);
  localparam type it_t = struct packed { logic [Cfg.XLEN-1:0] x; logic [Cfg.XLEN-1:0] y; };
  localparam it_t I = '{y: Cfg.XLEN'(2), x: Cfg.XLEN'(1)};
  assign b_o = a_i ? I.x : I.y;
endmodule
