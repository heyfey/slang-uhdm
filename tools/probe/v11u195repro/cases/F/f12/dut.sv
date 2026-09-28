// § funcCfgPatOpRefBare195 — v11u195 fresh: two patterns of the same function-sized struct type in one module
package cp;
  typedef struct packed { int unsigned XLEN; } cfg_t;
  function automatic cfg_t mk(int unsigned x); cfg_t r; r.XLEN = x; return r; endfunction
endpackage
module top #(parameter cp::cfg_t Cfg = cp::mk(8)) (input logic a, output logic [7:0] o);
  localparam int X = Cfg.XLEN;
  localparam type it_t = struct packed { logic [X-1:0] S; logic [X-1:0] M; };
  localparam it_t INT = '{S: 1, M: 3};
  localparam it_t INU = '{S: 2, M: 4};
  assign o = a ? INT.S : INU.M;
endmodule
