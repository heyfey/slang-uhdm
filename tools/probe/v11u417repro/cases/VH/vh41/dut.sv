// § hierSelParenBoundPretty417
module top (input logic clk, input logic [3:0] i, input logic [3:0] x, output logic [63:0] o);
  typedef struct packed { logic [63:0] d; } s_t;
  s_t s;
  always_ff @(posedge clk) s.d[(i*4)+:4] <= x;
  assign o = s.d;
endmodule
