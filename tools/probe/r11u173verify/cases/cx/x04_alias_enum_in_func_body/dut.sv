// § enumAliasClone161 § evalFuncBodyRhsStampClone167 — an aliased enum's member compared in the evaluated function body of a struct parameter
package cfg_pkg;
  typedef enum logic [1:0] { M0, M1, M2 } mode_e;
  typedef struct packed {
    int unsigned                 NrRules;
    logic [15:0][63:0]           Length;
    mode_e                       Mode;
  } user_cfg_t;
  typedef struct packed {
    int unsigned XLEN;
    logic        Flag;
  } cfg_t;
  function automatic cfg_t build_config(user_cfg_t c);
    cfg_t r;
    r.XLEN = 32;
    r.Flag = (c.Mode == M1) && (c.Length > 0);
    return r;
  endfunction
  localparam user_cfg_t Base = '{NrRules: unsigned'(2), Length: 1024'({64'b0, 64'b0}), Mode: M1};
endpackage
module sub #(parameter cfg_pkg::cfg_t Cfg = cfg_pkg::build_config(cfg_pkg::Base)) (output logic f_o, output logic [1:0] m);
  typedef cfg_pkg::mode_e md_t;
  md_t v;
  assign v = cfg_pkg::M2;
  assign m = v;
  assign f_o = Cfg.Flag;
endmodule
module top (output logic f, output logic [1:0] m);
  sub u1 (.f_o(f), .m(m));
endmodule
