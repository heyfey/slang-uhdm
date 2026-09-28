// § funcCfgPatOpRefBare195 — v11u195 fresh: a struct sized by $bits of the function-valued parameter, and one sized by a width-cast of its member
module top #(parameter int N = 2) (input logic c, output logic [7:0] o);
  typedef struct packed { int unsigned XLEN; } cfg_t;
  function automatic cfg_t mk(cfg_t x); cfg_t r; r.XLEN = x.XLEN; return r; endfunction
  localparam cfg_t Base = '{XLEN: 8};
  localparam cfg_t Cfg = mk(Base);
  localparam type it_t = struct packed { logic [Cfg.XLEN/2-1:0] S; logic [Cfg.XLEN/2-1:0] M; };
  localparam it_t INT = '{S: 4'd1, M: 4'd3};
  assign o = c ? INT : 8'd0;
endmodule
