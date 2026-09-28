// § tagPatParenSpan195 — v11u195 fresh: a function returning a pattern with a parenthesized formal, an unpacked-array index setter pattern in a package parameter, a macro-born paren
`define P(x) (x)
package p;
  localparam int A [3] = '{0: (1), 1: `P(2), default: (7)};
endpackage
module top (input logic [3:0] v, output logic [7:0] o, output int z);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  function automatic s_t mk(input logic [3:0] w);
    return '{a: (w), b: `P(w + 4'd1)};
  endfunction
  assign o = mk(v);
  assign z = p::A[1];
endmodule
