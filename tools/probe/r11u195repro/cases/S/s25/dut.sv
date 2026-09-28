// § funcCfgPatOpRefBare195 — grid S/s25 (r11u195)
package cp;
  typedef struct packed { int unsigned XLEN; } cfg_t;
  function automatic cfg_t mk(int unsigned x); cfg_t r; r.XLEN = x; return r; endfunction
endpackage
interface bus #(parameter cp::cfg_t Cfg = cp::mk(8));
  localparam type it_t = struct packed { logic [Cfg.XLEN-1:0] S; logic [Cfg.XLEN-1:0] M; };
  localparam it_t INT = '{S: 1, M: 3};
  logic [7:0] d;
  assign d = INT.S;
endinterface
module top(output logic [7:0] o);
  bus b();
  assign o = b.d;
endmodule
