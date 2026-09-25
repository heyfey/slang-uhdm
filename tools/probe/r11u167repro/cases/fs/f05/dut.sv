// § evalFuncBodyRhsStampClone167
package cfg_pkg;
  typedef struct packed {
    int unsigned                 XLEN;
    int unsigned                 NrRules;
    logic [15:0][63:0]           Length;
  } user_cfg_t;
  typedef struct packed {
    int unsigned XLEN;
    logic        Flag;
    logic        Flag2;
  } cfg_t;
  function automatic cfg_t build_config(user_cfg_t c);
    cfg_t r;
    r.XLEN = c.XLEN;
    r.Flag = (c.NrRules > 0) && (c.Length > 0);
    r.Flag2 = (c.NrRules > 1) || (c.Length == 0);
    return r;
  endfunction
  localparam user_cfg_t Base = '{
      XLEN: unsigned'(64),
      NrRules: unsigned'(2),
      Length: 1024'({64'b0, 64'b0})};
endpackage
module top import cfg_pkg::*; #(parameter cfg_t Cfg = build_config(Base)) (input logic a, output logic f_o);
  assign f_o = Cfg.Flag;
endmodule
