// § evalFuncBodyRhsStampClone167 § s2ClonePrecheck167v — a package function call over the formal member
package cfg_pkg;
  typedef struct packed { logic [15:0][63:0] Length; } sub_t;
  typedef struct packed {
    int unsigned                 XLEN;
    int unsigned                 NrRules;
    logic [15:0][63:0]           Length;
  } user_cfg_t;
  typedef struct packed {
    int unsigned XLEN;
    logic        Flag;
  } cfg_t;
  function automatic logic nz(logic [15:0][63:0] v);
    return v != 0;
  endfunction
  function automatic cfg_t build_config(user_cfg_t c);
    cfg_t r;
    r.XLEN = c.XLEN;
    r.Flag = nz(c.Length);
    return r;
  endfunction
  localparam user_cfg_t Base = '{
      XLEN: unsigned'(64),
      NrRules: unsigned'(2),
      Length: 1024'({64'b0, 64'b0})};
endpackage
module sub #(parameter cfg_pkg::cfg_t Cfg = cfg_pkg::build_config(cfg_pkg::Base)) (input logic a, output logic f_o);
  assign f_o = Cfg.Flag;
endmodule
module top (input logic a, output logic f, output logic g);
  sub u1 (.a(a), .f_o(f));
  sub u2 (.a(a), .f_o(g));
endmodule
