// § tagPatParenSpan195 — grid T/t05 (r11u195)
package p;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{default: (4)};
endpackage
module top (input logic [p::B.A-1:0] i, output logic o);
  assign o = i[0];
endmodule
