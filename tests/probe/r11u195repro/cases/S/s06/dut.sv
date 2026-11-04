// § funcCfgPatOpRefBare195 — grid S/s06 (r11u195)
package cp;
  typedef struct packed { int unsigned XLEN; } cfg_t;
  localparam cfg_t Def = '{XLEN: 32'd8};
endpackage
module top #(parameter cp::cfg_t Cfg = cp::Def) (input logic a, output logic [Cfg.XLEN-1:0] o);
  localparam type it_t = struct packed { logic [Cfg.XLEN-1:0] S; logic [Cfg.XLEN-1:0] M; };
  localparam it_t INT = '{S: Cfg.XLEN'(1), M: Cfg.XLEN'(3)};
  assign o = a ? INT.S : INT.M;
endmodule
