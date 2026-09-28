package cp;
  typedef struct packed { int unsigned XLEN; } cfg_t;
endpackage
module top #(parameter cp::cfg_t Cfg = '{XLEN: 32'd8}) (input logic a, output logic [Cfg.XLEN-1:0] o);
  localparam type it_t = struct packed { logic [Cfg.XLEN-1:0] S; logic [Cfg.XLEN-1:0] M; };
  localparam it_t INT = '{S: Cfg.XLEN'(1), M: Cfg.XLEN'(3)};
  assign o = a ? INT.S : INT.M;
endmodule
