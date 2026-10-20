// § hierSelParenBoundPretty417
package p;
  typedef struct packed { logic [15:0] d; } s_t;
endpackage
module top (input p::s_t s, input logic [1:0] i, output logic [3:0] o);
  assign o = s.d[(i*4)+:4];
endmodule
