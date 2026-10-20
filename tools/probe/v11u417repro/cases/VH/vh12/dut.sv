// § hierSelParenBoundPretty417
module top (input logic [3:0] i, output logic [3:0] o);
  typedef struct packed { logic [63:0] d; } s_t;
  function automatic logic [3:0] f(s_t s, logic [3:0] k);
    return s.d[(k*2)+:4];
  endfunction
  assign o = f('0, i);
endmodule
