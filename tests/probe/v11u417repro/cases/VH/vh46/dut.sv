// § hierSelParenBoundPretty417
package p;
  typedef struct packed { logic [15:0] d; } s_t;
endpackage
module top #(parameter int N = 8) (input p::s_t s, output logic [7:0] o);
  assign o = s.d[(N-1):0];
endmodule
