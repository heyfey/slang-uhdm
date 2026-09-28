// § funcCfgPatOpRefBare195 — grid S/s29 (r11u195): the evaluator gate, a member computed from a 1024-bit member (declines)
package cp;
  typedef struct packed { int unsigned XLEN; int unsigned N; logic [15:0][63:0] L; } u_t;
  typedef struct packed { int unsigned XLEN; logic F; } cfg_t;
  function automatic cfg_t mk(u_t c); cfg_t r; r.XLEN = c.XLEN; r.F = (c.N > 0) && (c.L > 0); return r; endfunction
  localparam u_t B = '{XLEN: 32'd8, N: 32'd2, L: 1024'(0)};
endpackage
module top #(parameter cp::cfg_t Cfg = cp::mk(cp::B)) (input logic a, output logic [7:0] o);
  localparam type it_t = struct packed { logic [Cfg.XLEN-1:0] S; logic [Cfg.XLEN-1:0] M; };
  localparam it_t INT = '{S: 1, M: 3};
  assign o = a ? INT.S : INT.M;
endmodule
