// § hierSelParenBoundPretty417
module top (input logic [3:0] i, output logic [3:0] o);
  typedef struct packed { logic [63:0] d; } s_t;
  s_t [1:0] s;
  assign o = s[1].d[(i)+:4];
endmodule
