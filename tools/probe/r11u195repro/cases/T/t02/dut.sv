// § tagPatParenSpan195 — grid T/t02 (r11u195)
package p;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam int L = 3;
  localparam cfg_t B = '{A:((2)), D:(L + 1)};
endpackage
module top (input logic [p::B.A-1:0] i, output logic o);
  assign o = i[0];
endmodule
