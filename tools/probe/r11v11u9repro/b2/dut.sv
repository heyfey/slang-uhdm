// b2 — StructParamFuncBodyFieldCompare's bail shape with a PACKAGE holder.
package cfg_pkg;
  parameter int unsigned NrMaxRules = 16;
  typedef struct packed {
    int unsigned                 XLEN;
    int unsigned                 NrRules;
    logic [NrMaxRules-1:0][63:0] Length;
  } user_cfg_t;
  typedef struct packed {
    int unsigned XLEN;
    logic        Flag;
  } cfg_t;
  function automatic cfg_t build_config(user_cfg_t c);
    cfg_t r;
    r.XLEN = c.XLEN;
    r.Flag = (c.NrRules > 0) && (c.Length > 0);
    return r;
  endfunction
  localparam user_cfg_t Base = '{
      XLEN: unsigned'(64),
      NrRules: unsigned'(2),
      Length: 1024'({64'b0, 64'b0})};
  localparam cfg_t Cfg = build_config(Base);
endpackage

module b2_child import cfg_pkg::*; (
    input  logic                a_i,
    output logic [Cfg.XLEN-1:0] b_o,
    output logic                f_o
);
  assign b_o = {Cfg.XLEN{a_i}};
  assign f_o = Cfg.Flag;
endmodule
