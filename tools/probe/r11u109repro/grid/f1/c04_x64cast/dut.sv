package cfg_pkg;
  typedef struct packed { int unsigned XLEN; } user_cfg_t;
  typedef struct packed { int unsigned XLEN; } cfg_t;
  function automatic cfg_t build_config(user_cfg_t c);
    cfg_t r;
    r.XLEN = c.XLEN;
    return r;
  endfunction
  localparam user_cfg_t Base = '{XLEN: 32'd64};
endpackage
module dut #(parameter cfg_pkg::cfg_t Cfg = cfg_pkg::build_config(cfg_pkg::Base)) (input logic a_i, output logic [Cfg.XLEN-1:0] b_o);
  localparam type it_t = struct packed { logic [Cfg.XLEN-1:0] S_SW; logic [Cfg.XLEN-1:0] M_SW; };
  localparam it_t INT = '{ S_SW: Cfg.XLEN'(1), M_SW: Cfg.XLEN'(2) };
  assign b_o = a_i ? INT.S_SW : INT.M_SW;
endmodule
