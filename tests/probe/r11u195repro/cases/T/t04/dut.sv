// § tagPatParenSpan195 — grid T/t04 (r11u195)
module top (input logic [3:0] i, output logic o);
  localparam int A [2] = '{0: (8), 1: 3};
  assign o = i[A[1]];
endmodule
