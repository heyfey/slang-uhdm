// § hierSelParenBoundPretty417
module sub (input logic [3:0] a, output logic [3:0] y);
  assign y = a;
endmodule
module top (input logic [3:0] i, output logic [3:0] o);
  typedef struct packed { logic [63:0] d; } s_t;
  s_t s;
  sub u (.a(s.d[(i*2)+:4]), .y(o));
endmodule
