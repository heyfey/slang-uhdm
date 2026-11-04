// § funcCfgPatOpRefBare195 — grid S/s10 (r11u195)
package cp;
  typedef struct packed { int unsigned XLEN; } cfg_t;
  function automatic cfg_t mk(int unsigned x); cfg_t r; r.XLEN = x; return r; endfunction
endpackage
module top #(parameter cp::cfg_t Cfg = cp::mk(8)) (input logic a, output logic [7:0] o);
  localparam type it_t = struct packed { logic [7:0] S; logic [7:0] M; };
  localparam it_t INT = '{S: Cfg.XLEN'(1), M: Cfg.XLEN'(3)};
  assign o = a ? INT.S : INT.M;
endmodule
