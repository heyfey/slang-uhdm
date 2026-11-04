// § tagPatParenSpan195 — v11u195 fresh: a function returning a pattern with a parenthesized formal and a parenthesized sum
module top (input logic [3:0] v, output logic [7:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  function automatic s_t mk(input logic [3:0] w);
    return '{a: (w), b: (w + 4'd1)};
  endfunction
  assign o = mk(v);
endmodule
