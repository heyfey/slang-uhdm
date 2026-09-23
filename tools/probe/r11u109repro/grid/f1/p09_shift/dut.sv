package cfg_pkg;
  typedef struct packed { int unsigned XLEN; int unsigned VLEN; } cfg_t;
  localparam cfg_t DefaultCfg = '{XLEN: 32'd64, VLEN: 32'd64};
endpackage
module dut #(parameter cfg_pkg::cfg_t Cfg = cfg_pkg::DefaultCfg) (input logic a_i, output logic [Cfg.XLEN-1:0] b_o);
  localparam type it_t = struct packed { logic [Cfg.XLEN-1:0] S_SW; logic [Cfg.XLEN-1:0] M_SW; };
  localparam it_t INT = '{ S_SW: (Cfg.XLEN'(1) << (Cfg.XLEN - 1)) | Cfg.XLEN'(1), M_SW: (Cfg.XLEN'(1) << (Cfg.XLEN - 1)) | Cfg.XLEN'(3) };
  assign b_o = a_i ? INT.S_SW : INT.M_SW;
endmodule
