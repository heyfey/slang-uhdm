// § funcCfgPatOpRefBare195 — v11u195 fresh: the function body with an if statement (outside the modelled straight-copy shape: declines)
package cp;
  typedef struct packed { int unsigned XLEN; } cfg_t;
  function automatic cfg_t mk(int unsigned x); cfg_t r; r.XLEN = x; if (x > 16) r.XLEN = 16; return r; endfunction
endpackage
module top #(parameter cp::cfg_t Cfg = cp::mk(8)) (input logic a, output logic [7:0] o);
  localparam type it_t = struct packed { logic [Cfg.XLEN-1:0] S; logic [Cfg.XLEN-1:0] M; };
  localparam it_t INT = '{S: 1, M: 3};
  assign o = a ? INT.S : INT.M;
endmodule
