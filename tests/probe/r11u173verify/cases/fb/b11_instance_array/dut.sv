// § evalFuncBodyRhsStampClone167 § s2ClonePrecheck167v — the evalFunc parameter of an instance array
package cfg_pkg;
  typedef struct packed {
    int unsigned                 NrRules;
    logic [15:0][63:0]           Length;
  } user_cfg_t;
  typedef struct packed {
    int unsigned XLEN;
    logic        Flag;
  } cfg_t;
  function automatic cfg_t build_config(user_cfg_t c);
    cfg_t r;
    r.XLEN = 32;
    r.Flag = (c.NrRules > 0) && (c.Length > 0);
    return r;
  endfunction
  localparam user_cfg_t Base = '{NrRules: unsigned'(2), Length: 1024'({64'b0, 64'b0})};
endpackage
module sub #(parameter cfg_pkg::cfg_t Cfg = cfg_pkg::build_config(cfg_pkg::Base)) (output logic f_o);
  assign f_o = Cfg.Flag;
endmodule
module top (output logic [1:0] f);
  sub u [1:0] (.f_o(f));
endmodule
