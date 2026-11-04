// § tagPatParenSpan195 — grid T/t08 (r11u195)
`include "defs.svh"
module top (input logic [3:0] i, output logic o);
  typedef struct packed { logic [3:0] A; logic [3:0] D; } cfg_t;
  localparam cfg_t B = '{A:`V2, D:`PAR(4'd1)};
  assign o = i[B.A];
endmodule
