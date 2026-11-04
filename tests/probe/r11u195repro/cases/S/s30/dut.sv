// § funcCfgPatOpRefBare195 — grid S/s30 (r11u195): the evaluator gate, a member computed by an operation (the model declines)
package cp;
  typedef struct packed { int unsigned XLEN; } cfg_t;
  function automatic cfg_t mk(int unsigned x); cfg_t r; r.XLEN = x * 2; return r; endfunction
endpackage
module top #(parameter cp::cfg_t Cfg = cp::mk(4)) (input logic a, output logic [7:0] o);
  localparam type it_t = struct packed { logic [Cfg.XLEN-1:0] S; logic [Cfg.XLEN-1:0] M; };
  localparam it_t INT = '{S: 1, M: 3};
  assign o = a ? INT.S : INT.M;
endmodule
