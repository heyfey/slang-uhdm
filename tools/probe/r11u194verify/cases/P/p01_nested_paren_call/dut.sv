// § memberSelParenIdxSpan184: nested parentheses, a parenthesized call and a parenthesized unary operand as a trailing member-select index (rvalues)
module top (input logic [1:0] i, output logic a, output logic b, output logic c, output logic d);
  typedef struct packed { logic [3:0] f; logic [3:0] g; } s_t;
  s_t s;
  function automatic logic [1:0] fn(input logic [1:0] x); return x + 2'd1; endfunction
  always_comb begin
    a = s.f[((i))];
    b = s.g[(fn(i))];
    c = s.f[(~i)];
    d = s.g[(i + 2'd1)];
  end
endmodule
