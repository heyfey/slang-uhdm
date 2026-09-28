// § tagPatParenSpan195 — grid T/t06 (r11u195)
module top (input logic [3:0] i, output logic o);
  typedef struct packed { logic [3:0] A; logic [3:0] D; } cfg_t;
  localparam cfg_t B = '{A:(4'd2), D:4'd1};
  assign o = i[B.A];
endmodule
