// § hierSelParenBoundPretty417
module top (input logic [3:0] i, output logic [3:0] o);
  typedef struct packed { logic [63:0] d; } s_t;
  s_t s;
  function automatic int g(int k); return k * 2; endfunction
  assign o = s.d[g(i)+:4];
endmodule
