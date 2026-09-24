package cfg_pkg;
  parameter int unsigned NrMaxRules = 16;
  typedef struct packed { int unsigned XLEN; int unsigned NrRules; logic [NrMaxRules-1:0][63:0] Length; } user_cfg_t;
  typedef struct packed { int unsigned XLEN; logic Flag; } cfg_t;
  function automatic cfg_t build_config(user_cfg_t c);
    cfg_t r;
    r.XLEN = c.XLEN;
    r.Flag = (c.NrRules > 0) && (c.Length > 0);
    return r;
  endfunction
  localparam user_cfg_t Base = '{XLEN: unsigned'(32), NrRules: unsigned'(2), Length: 1024'({64'b0, 64'b0})};
endpackage
module dut #(parameter cfg_pkg::cfg_t Cfg = cfg_pkg::build_config(cfg_pkg::Base)) (input logic a_i, output logic [Cfg.XLEN-1:0] b_o, output logic f_o);
  localparam type it_t = struct packed { logic [Cfg.XLEN-1:0] S_SW; logic [Cfg.XLEN-1:0] M_SW; };
  localparam it_t INT = '{ S_SW: (Cfg.XLEN'(1) << (Cfg.XLEN - 1)) | Cfg.XLEN'(1), M_SW: Cfg.XLEN'(3) };
  assign b_o = a_i ? INT.S_SW : INT.M_SW;
  assign f_o = Cfg.Flag;
endmodule
