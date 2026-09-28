package cp;
  typedef struct packed { int unsigned XLEN; } cfg_t;
endpackage
module top #(parameter cp::cfg_t Cfg = '{XLEN: 32'd8}) (input logic a, output logic [7:0] o);
  typedef struct packed { logic [7:0] S; logic [7:0] M; } it_t;
  localparam it_t INT = '{S: Cfg.XLEN, M: 8'd3};
  assign o = a ? INT.S : INT.M;
endmodule
